import 'package:dartz/dartz.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';

part 'entity.g.dart';

Option optionFromJson(dynamic json) => optionOf(json);
dynamic optionToJson(Option opts) => opts.toNullable();

@immutable
@JsonSerializable()
class AppConfig {
  @JsonKey(name: 'base_url', fromJson: optionFromJson, toJson: optionToJson)
  final Option<String> baseUrl;

  @JsonKey(
    name: 'broker_lb_url',
    fromJson: optionFromJson,
    toJson: optionToJson,
  )
  final Option<String> brokerLbUrl;

  @JsonKey(name: 'broker_url', fromJson: optionFromJson, toJson: optionToJson)
  final Option<String> brokerUrl;

  @JsonKey(
    name: 'enable_event_report',
    fromJson: optionFromJson,
    toJson: optionToJson,
  )
  final Option<bool> enableEventReport;

  @JsonKey(
    name: 'enable_realtime',
    fromJson: optionFromJson,
    toJson: optionToJson,
  )
  final Option<bool> enableRealtime;

  @JsonKey(
    name: 'enable_realtime_check',
    fromJson: optionFromJson,
    toJson: optionToJson,
  )
  final Option<bool> enableRealtimeCheck;

  @JsonKey(name: 'extras', fromJson: optionFromJson, toJson: optionToJson)
  final Option<Map<String, dynamic>> extras;

  @JsonKey(
    name: 'sync_interval',
    fromJson: optionFromJson,
    toJson: optionToJson,
  )
  final Option<int> syncInterval;

  @JsonKey(
    name: 'sync_on_connect',
    fromJson: optionFromJson,
    toJson: optionToJson,
  )
  final Option<int> syncOnConnect;

  AppConfig({
    @required this.baseUrl,
    @required this.brokerLbUrl,
    @required this.brokerUrl,
    @required this.enableEventReport,
    @required this.enableRealtime,
    @required this.enableRealtimeCheck,
    @required this.extras,
    @required this.syncInterval,
    @required this.syncOnConnect,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);
  void hydrateStorage(Storage s) {
    baseUrl.do_((it) => s.baseUrl = it);
    baseUrl.do_((it) => s.baseUrl = it);
    brokerLbUrl.do_((it) => s.brokerLbUrl = it);
    brokerUrl.do_((it) => s.brokerUrl = it);
    enableEventReport.do_((it) => s.enableEventReport = it);
    enableRealtime.do_((it) => s.isRealtimeEnabled = it);
    enableRealtimeCheck.do_((it) => s.isRealtimeCheckEnabled = it);
    syncInterval.do_((it) => s.syncInterval = it);
    syncOnConnect.do_((it) => s.syncIntervalWhenConnected = it);
    extras.do_((it) => s.configExtras = it);
  }
}
