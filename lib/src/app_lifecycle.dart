import 'package:flutter/widgets.dart'
    show AppLifecycleState, WidgetsBinding, WidgetsBindingObserver;
import 'package:mqtt_client/mqtt_client.dart' show MqttClient;

/// `WidgetsBinding` yang sedang aktif, atau `null` bila belum ada.
///
/// SDK TIDAK BOLEH memanggil `WidgetsFlutterBinding.ensureInitialized()`
/// sendiri: SDK juga dipakai di test Dart murni dan di isolate background
/// (mis. handler FCM) yang tidak punya binding. Membuat binding di sana
/// mengubah perilaku aplikasi tanpa sepengetahuannya.
///
/// Di Flutter 2.x getter `instance` bertipe nullable dan mengembalikan `null`
/// bila belum di-inisialisasi. Sejak Flutter 3.0 getter-nya non-nullable dan
/// MELEMPAR bila belum di-inisialisasi (`FlutterError` dari assert di mode
/// debug, error null-check di mode release). Fungsi ini menyamakan keduanya:
/// return type nullable + try/catch.
WidgetsBinding? maybeWidgetsBinding() {
  try {
    return WidgetsBinding.instance;
  } catch (_) {
    return null;
  }
}

/// Memanggil [onResumed] setiap kali aplikasi kembali ke foreground
/// ([AppLifecycleState.resumed]), dengan debounce.
///
/// Debounce mencegah rentetan resume (mis. dialog izin sistem, app switcher,
/// atau aplikasi yang juga memanggil `handleAppResumed()` dari observer-nya
/// sendiri) memborbardir endpoint sync.
class AppResumeSync with WidgetsBindingObserver {
  AppResumeSync({
    required this.onResumed,
    this.debounce = defaultDebounce,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  static const defaultDebounce = Duration(seconds: 2);

  /// Dikerjakan saat resume. Mengembalikan `false` bila tidak ada yang
  /// dikerjakan (mis. user belum login), supaya resume tersebut tidak
  /// membuka jendela debounce.
  final bool Function() onResumed;
  final Duration debounce;
  final DateTime Function() _now;

  WidgetsBinding? _binding;
  DateTime? _lastRun;

  bool get isAttached => _binding != null;

  /// Daftarkan observer ke binding yang SUDAH ada. Idempoten.
  ///
  /// Mengembalikan `false` bila belum ada binding; tidak ada yang didaftarkan
  /// dan pemanggil boleh mencoba lagi nanti.
  bool attach() {
    if (_binding != null) return true;
    var binding = maybeWidgetsBinding();
    if (binding == null) return false;
    binding.addObserver(this);
    _binding = binding;
    return true;
  }

  /// Lepas observer dan reset debounce. Aman dipanggil berulang kali.
  void detach() {
    _binding?.removeObserver(this);
    _binding = null;
    _lastRun = null;
  }

  /// Jalankan [onResumed] kecuali masih dalam jendela debounce dari run
  /// sebelumnya. Mengembalikan `true` bila [onResumed] benar-benar bekerja.
  bool trigger() {
    var now = _now();
    var last = _lastRun;
    if (last != null && now.difference(last) < debounce) return false;
    if (!onResumed()) return false;
    _lastRun = now;
    return true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) trigger();
  }
}

/// Status koneksi realtime yang dimiliki SDK, diturunkan dari callback PUBLIK
/// [MqttClient] (`onConnected`, `onAutoReconnect`, `onAutoReconnected`,
/// `onDisconnected`).
///
/// Dipakai untuk membedakan tiga keadaan saat resume tanpa membaca field
/// `@protected` milik mqtt_client (`connectionHandler`,
/// `initialConnectionComplete`, `autoReconnectInProgress`):
///  - belum pernah connect sukses -> mqtt_client tidak pernah retry sendiri,
///    jadi SDK harus menjalankan jalur connect normalnya;
///  - pernah connect lalu putus -> mqtt_client auto reconnect; SDK hanya
///    memicunya bila belum berjalan (dua connect bersamaan membuat dua client
///    dengan client id sama yang saling menendang);
///  - sedang terhubung -> tidak ada yang dikerjakan.
class MqttConnectionTracker {
  MqttConnectionTracker(this._client);

  final MqttClient _client;
  bool _installed = false;
  bool _hasConnected = false;
  bool _autoReconnecting = false;

  /// `true` bila koneksi pernah sukses sejak connect/disconnect sengaja
  /// terakhir.
  bool get hasConnected => _hasConnected;

  /// `true` selama mqtt_client sedang menjalankan auto reconnect.
  bool get autoReconnectInProgress => _autoReconnecting;

  /// Pasang hook ke callback client. Idempoten. Callback yang sudah ada
  /// DIRANTAI (dipanggil setelah hook ini), tidak ditimpa.
  ///
  /// mqtt_client mengambil snapshot callback saat `connect()`, jadi ini harus
  /// dipanggil SEBELUM connect.
  void install() {
    if (_installed) return;
    _installed = true;

    var onConnected = _client.onConnected;
    _client.onConnected = () {
      _hasConnected = true;
      _autoReconnecting = false;
      onConnected?.call();
    };

    var onAutoReconnect = _client.onAutoReconnect;
    _client.onAutoReconnect = () {
      _autoReconnecting = true;
      onAutoReconnect?.call();
    };

    var onAutoReconnected = _client.onAutoReconnected;
    _client.onAutoReconnected = () {
      _autoReconnecting = false;
      onAutoReconnected?.call();
    };

    // Dengan `autoReconnect = true` callback ini hanya terpanggil pada
    // disconnect yang disengaja: riwayat koneksi dimulai dari awal lagi.
    var onDisconnected = _client.onDisconnected;
    _client.onDisconnected = () {
      _hasConnected = false;
      _autoReconnecting = false;
      onDisconnected?.call();
    };
  }
}
