// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room-with-messages.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$QChatRoom {
  int get id => throw _privateConstructorUsedError;
  String get uniqueId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  Map<String, Object?>? get extras => throw _privateConstructorUsedError;
  QMessage? get lastMessage => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  int get totalParticipants => throw _privateConstructorUsedError;
  List<QParticipant> get participants => throw _privateConstructorUsedError;
  QRoomType get type => throw _privateConstructorUsedError;
  List<QMessage> get messages => throw _privateConstructorUsedError;

  /// Create a copy of QChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QChatRoomCopyWith<QChatRoom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QChatRoomCopyWith<$Res> {
  factory $QChatRoomCopyWith(QChatRoom value, $Res Function(QChatRoom) then) =
      _$QChatRoomCopyWithImpl<$Res, QChatRoom>;
  @useResult
  $Res call(
      {int id,
      String uniqueId,
      String name,
      String? avatarUrl,
      Map<String, Object?>? extras,
      QMessage? lastMessage,
      int unreadCount,
      int totalParticipants,
      List<QParticipant> participants,
      QRoomType type,
      List<QMessage> messages});
}

/// @nodoc
class _$QChatRoomCopyWithImpl<$Res, $Val extends QChatRoom>
    implements $QChatRoomCopyWith<$Res> {
  _$QChatRoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? uniqueId = null,
    Object? name = null,
    Object? avatarUrl = freezed,
    Object? extras = freezed,
    Object? lastMessage = freezed,
    Object? unreadCount = null,
    Object? totalParticipants = null,
    Object? participants = null,
    Object? type = null,
    Object? messages = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      uniqueId: null == uniqueId
          ? _value.uniqueId
          : uniqueId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      extras: freezed == extras
          ? _value.extras
          : extras // ignore: cast_nullable_to_non_nullable
              as Map<String, Object?>?,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as QMessage?,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalParticipants: null == totalParticipants
          ? _value.totalParticipants
          : totalParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<QParticipant>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as QRoomType,
      messages: null == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<QMessage>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QChatRoomImplCopyWith<$Res>
    implements $QChatRoomCopyWith<$Res> {
  factory _$$QChatRoomImplCopyWith(
          _$QChatRoomImpl value, $Res Function(_$QChatRoomImpl) then) =
      __$$QChatRoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String uniqueId,
      String name,
      String? avatarUrl,
      Map<String, Object?>? extras,
      QMessage? lastMessage,
      int unreadCount,
      int totalParticipants,
      List<QParticipant> participants,
      QRoomType type,
      List<QMessage> messages});
}

/// @nodoc
class __$$QChatRoomImplCopyWithImpl<$Res>
    extends _$QChatRoomCopyWithImpl<$Res, _$QChatRoomImpl>
    implements _$$QChatRoomImplCopyWith<$Res> {
  __$$QChatRoomImplCopyWithImpl(
      _$QChatRoomImpl _value, $Res Function(_$QChatRoomImpl) _then)
      : super(_value, _then);

  /// Create a copy of QChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? uniqueId = null,
    Object? name = null,
    Object? avatarUrl = freezed,
    Object? extras = freezed,
    Object? lastMessage = freezed,
    Object? unreadCount = null,
    Object? totalParticipants = null,
    Object? participants = null,
    Object? type = null,
    Object? messages = null,
  }) {
    return _then(_$QChatRoomImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      uniqueId: null == uniqueId
          ? _value.uniqueId
          : uniqueId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      extras: freezed == extras
          ? _value._extras
          : extras // ignore: cast_nullable_to_non_nullable
              as Map<String, Object?>?,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as QMessage?,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalParticipants: null == totalParticipants
          ? _value.totalParticipants
          : totalParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      participants: null == participants
          ? _value._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<QParticipant>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as QRoomType,
      messages: null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<QMessage>,
    ));
  }
}

/// @nodoc

class _$QChatRoomImpl implements _QChatRoom {
  const _$QChatRoomImpl(
      {required this.id,
      required this.uniqueId,
      required this.name,
      this.avatarUrl,
      final Map<String, Object?>? extras,
      this.lastMessage,
      this.unreadCount = 0,
      this.totalParticipants = 0,
      final List<QParticipant> participants = const <QParticipant>[],
      this.type = QRoomType.single,
      final List<QMessage> messages = const <QMessage>[]})
      : _extras = extras,
        _participants = participants,
        _messages = messages;

  @override
  final int id;
  @override
  final String uniqueId;
  @override
  final String name;
  @override
  final String? avatarUrl;
  final Map<String, Object?>? _extras;
  @override
  Map<String, Object?>? get extras {
    final value = _extras;
    if (value == null) return null;
    if (_extras is EqualUnmodifiableMapView) return _extras;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final QMessage? lastMessage;
  @override
  @JsonKey()
  final int unreadCount;
  @override
  @JsonKey()
  final int totalParticipants;
  final List<QParticipant> _participants;
  @override
  @JsonKey()
  List<QParticipant> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  @JsonKey()
  final QRoomType type;
  final List<QMessage> _messages;
  @override
  @JsonKey()
  List<QMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  String toString() {
    return 'QChatRoom(id: $id, uniqueId: $uniqueId, name: $name, avatarUrl: $avatarUrl, extras: $extras, lastMessage: $lastMessage, unreadCount: $unreadCount, totalParticipants: $totalParticipants, participants: $participants, type: $type, messages: $messages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QChatRoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.uniqueId, uniqueId) ||
                other.uniqueId == uniqueId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            const DeepCollectionEquality().equals(other._extras, _extras) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.totalParticipants, totalParticipants) ||
                other.totalParticipants == totalParticipants) &&
            const DeepCollectionEquality()
                .equals(other._participants, _participants) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._messages, _messages));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      uniqueId,
      name,
      avatarUrl,
      const DeepCollectionEquality().hash(_extras),
      lastMessage,
      unreadCount,
      totalParticipants,
      const DeepCollectionEquality().hash(_participants),
      type,
      const DeepCollectionEquality().hash(_messages));

  /// Create a copy of QChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QChatRoomImplCopyWith<_$QChatRoomImpl> get copyWith =>
      __$$QChatRoomImplCopyWithImpl<_$QChatRoomImpl>(this, _$identity);
}

abstract class _QChatRoom implements QChatRoom {
  const factory _QChatRoom(
      {required final int id,
      required final String uniqueId,
      required final String name,
      final String? avatarUrl,
      final Map<String, Object?>? extras,
      final QMessage? lastMessage,
      final int unreadCount,
      final int totalParticipants,
      final List<QParticipant> participants,
      final QRoomType type,
      final List<QMessage> messages}) = _$QChatRoomImpl;

  @override
  int get id;
  @override
  String get uniqueId;
  @override
  String get name;
  @override
  String? get avatarUrl;
  @override
  Map<String, Object?>? get extras;
  @override
  QMessage? get lastMessage;
  @override
  int get unreadCount;
  @override
  int get totalParticipants;
  @override
  List<QParticipant> get participants;
  @override
  QRoomType get type;
  @override
  List<QMessage> get messages;

  /// Create a copy of QChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QChatRoomImplCopyWith<_$QChatRoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
