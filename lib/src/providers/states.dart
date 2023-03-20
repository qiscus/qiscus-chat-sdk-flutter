import 'package:riverpod/riverpod.dart';

import '../core.dart';

const defaultBaseUrl = 'https://api3.qiscus.com';
const defaultUploadUrl = '$defaultBaseUrl/api/v2/sdk/upload';
const defaultBrokerUrl = 'realtime-bali.qiscus.com';
const defaultBrokerLbUrl = 'https://realtime-lb.qiscus.com';
const defaultAccInterval = 1000;
const defaultSyncInterval = 5000;
const defaultSyncIntervalWhenConnected = 30000;

final appIdProvider = Provider<String?>((_) => null);
final baseUrlProvider = Provider<String>((_) => defaultBaseUrl);
final brokerLbUrlProvider = Provider<String>((_) => defaultBrokerLbUrl);
final brokerUrlProvider = Provider<String>((_) => defaultBrokerUrl);
final enableEventReportProvider = Provider<bool>((_) => false);
final enableRealtimeProvider = Provider<bool>((_) => true);
final enableRealtimeCheckProvider = Provider<bool>((_) => true);
final extrasProvider = Provider<Json?>((_) => null);
final syncIntervalProvider = Provider<int>((_) => defaultSyncInterval);
final syncOnConnectProvider =
    Provider<int>((_) => defaultSyncIntervalWhenConnected);
