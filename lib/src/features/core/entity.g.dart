// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) {
  return AppConfig(
    baseUrl: optionFromJson(json['base_url']),
    brokerLbUrl: optionFromJson(json['broker_lb_url']),
    brokerUrl: optionFromJson(json['broker_url']),
    enableEventReport: optionFromJson(json['enable_event_report']),
    enableRealtime: optionFromJson(json['enable_realtime']),
    enableRealtimeCheck: optionFromJson(json['enable_realtime_check']),
    extras: optionFromJson(json['extras']),
    syncInterval: optionFromJson(json['sync_interval']),
    syncOnConnect: optionFromJson(json['sync_on_connect']),
  );
}

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) => <String, dynamic>{
      'base_url': optionToJson(instance.baseUrl),
      'broker_lb_url': optionToJson(instance.brokerLbUrl),
      'broker_url': optionToJson(instance.brokerUrl),
      'enable_event_report': optionToJson(instance.enableEventReport),
      'enable_realtime': optionToJson(instance.enableRealtime),
      'enable_realtime_check': optionToJson(instance.enableRealtimeCheck),
      'extras': optionToJson(instance.extras),
      'sync_interval': optionToJson(instance.syncInterval),
      'sync_on_connect': optionToJson(instance.syncOnConnect),
    };
