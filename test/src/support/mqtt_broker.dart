import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Minimal loopback broker: real mqtt_client connect, subscribe, reconnect and
/// disconnect processing, without a remote service or replacing its callbacks.
class TestMqttBroker {
  TestMqttBroker._(this.server, this.rejectSubscribe);

  final ServerSocket server;

  /// Filter yang dijawab SUBACK 0x80 (gagal); `null` = terima semua.
  final bool Function(String filter)? rejectSubscribe;

  /// Seperti broker produksi (`mochi-mqtt.qiscus.com`): tolak filter topic
  /// room `r/...` yang memakai wildcard.
  static bool rejectRoomWildcards(String filter) =>
      filter.startsWith('r/') && filter.contains('+');

  /// Filter yang ditolak, untuk asersi.
  final rejected = <String>[];
  final peers = <_Peer>[];
  late final StreamSubscription<Socket> _connections;
  int connections = 0;

  /// Grant SUBACK paksa untuk semua filter (0x80 = gagal, -1 = SUBACK
  /// kosong); `null` = berikan QoS yang diminta.
  int? subscriptionGrant;

  static Future<TestMqttBroker> start({
    int port = 0,
    bool Function(String filter)? rejectSubscribe,
  }) async {
    final broker = TestMqttBroker._(
        await ServerSocket.bind(InternetAddress.loopbackIPv4, port),
        rejectSubscribe);
    broker._connections = broker.server.listen((socket) {
      broker.connections++;
      final peer = _Peer(socket, broker);
      broker.peers.add(peer);
      peer.subscription = socket.listen(peer.receive, onDone: () {
        broker.peers.remove(peer);
      });
    });
    return broker;
  }

  int get port => server.port;

  bool subscribed(String topic) =>
      peers.any((peer) => peer.topics.contains(topic));

  Future<void> publish(String topic, Map<String, Object?> message) async {
    final topicBytes = utf8.encode(topic);
    final payload = [
      topicBytes.length >> 8,
      topicBytes.length & 255,
      ...topicBytes,
      ...utf8.encode(jsonEncode(message)),
    ];
    for (final peer in peers.where((peer) => peer.topics.contains(topic))) {
      peer.send(0x30, payload);
      await peer.socket.flush();
    }
  }

  /// Publish [payload] apa adanya (bukan JSON) ke [topic], dikirim ke peer
  /// yang subscribe [filter] (default: [topic]). Receipt Qiscus berformat
  /// `id:uniqueId` dan datang di topic konkret seperti `r/1/5/user/d`,
  /// sedangkan SDK subscribe memakai wildcard `r/1/+/+/d`.
  Future<void> publishRaw(String topic, String payload,
      {String? filter}) async {
    final topicBytes = utf8.encode(topic);
    final bytes = [
      topicBytes.length >> 8,
      topicBytes.length & 255,
      ...topicBytes,
      ...utf8.encode(payload),
    ];
    final match = filter ?? topic;
    for (final peer in peers.where((peer) => peer.topics.contains(match))) {
      peer.send(0x30, bytes);
      await peer.socket.flush();
    }
  }

  Future<void> close() async {
    await _connections.cancel();
    for (final peer in peers.toList()) {
      await peer.subscription.cancel();
      peer.socket.destroy();
    }
    peers.clear();
    await server.close();
  }
}

class _Peer {
  _Peer(this.socket, this.broker);

  final Socket socket;
  final TestMqttBroker broker;
  final topics = <String>{};
  final buffer = <int>[];
  late final StreamSubscription<List<int>> subscription;

  void send(int header, List<int> payload) {
    var remaining = payload.length;
    final length = <int>[];
    do {
      var byte = remaining % 128;
      remaining ~/= 128;
      if (remaining > 0) byte |= 128;
      length.add(byte);
    } while (remaining > 0);
    socket.add([header, ...length, ...payload]);
  }

  void receive(List<int> bytes) {
    buffer.addAll(bytes);
    while (buffer.length >= 2) {
      var remaining = 0, multiplier = 1, offset = 1;
      int byte;
      do {
        if (offset >= buffer.length) return;
        byte = buffer[offset++];
        remaining += (byte & 127) * multiplier;
        multiplier *= 128;
      } while ((byte & 128) != 0);
      if (buffer.length < offset + remaining) return;
      final type = buffer.first >> 4;
      final payload = buffer.sublist(offset, offset + remaining);
      buffer.removeRange(0, offset + remaining);
      switch (type) {
        case 1: // CONNECT
          send(0x20, [0, 0]);
          break;
        case 8: // SUBSCRIBE (one or more topic filters)
          var index = 2;
          final grants = <int>[];
          while (index < payload.length) {
            final length = (payload[index] << 8) | payload[index + 1];
            index += 2;
            final topic = utf8.decode(payload.sublist(index, index + length));
            index += length;
            final requested = payload[index++];
            if (broker.rejectSubscribe?.call(topic) ?? false) {
              broker.rejected.add(topic);
              grants.add(0x80);
              continue;
            }
            final grant = broker.subscriptionGrant ?? requested;
            if (grant != 0x80 && grant != -1) topics.add(topic);
            if (grant != -1) grants.add(grant);
          }
          send(0x90, [payload[0], payload[1], ...grants]);
          break;
        case 10: // UNSUBSCRIBE
          var index = 2;
          while (index < payload.length) {
            final length = (payload[index] << 8) | payload[index + 1];
            index += 2;
            topics.remove(utf8.decode(payload.sublist(index, index + length)));
            index += length;
          }
          send(0xb0, [payload[0], payload[1]]);
          break;
        case 12: // PINGREQ
          send(0xd0, []);
          break;
        case 14: // DISCONNECT
          socket.destroy();
          break;
      }
    }
  }
}

Future<void> waitFor(bool Function() condition) async {
  final clock = Stopwatch()..start();
  while (!condition()) {
    if (clock.elapsed > const Duration(seconds: 5)) {
      throw TimeoutException('Loopback MQTT condition was not reached');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

Map<String, Object?> mqttComment(int id) => {
      'id': id,
      'room_id': 1,
      'comment_before_id': id - 1,
      'unique_temp_id': 'unique-$id',
      'message': 'message-$id',
      'type': 'text',
      'status': 'sent',
      'unix_nano_timestamp': 1600000000000000000 + id * 1000000000,
      'email': 'sender-id',
      'username': 'sender-name',
      'user_avatar_url': 'https://example.com/avatar.png',
    };
