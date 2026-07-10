// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sse_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SseEventEventEnum _$sseEventEventEnum_tracksUpdated =
    const SseEventEventEnum._('tracksUpdated');
const SseEventEventEnum _$sseEventEventEnum_trackUpdated =
    const SseEventEventEnum._('trackUpdated');
const SseEventEventEnum _$sseEventEventEnum_cornersUpdated =
    const SseEventEventEnum._('cornersUpdated');
const SseEventEventEnum _$sseEventEventEnum_groupsUpdated =
    const SseEventEventEnum._('groupsUpdated');
const SseEventEventEnum _$sseEventEventEnum_campUpdated =
    const SseEventEventEnum._('campUpdated');
const SseEventEventEnum _$sseEventEventEnum_messagesChanged =
    const SseEventEventEnum._('messagesChanged');
const SseEventEventEnum _$sseEventEventEnum_trackDeleted =
    const SseEventEventEnum._('trackDeleted');
const SseEventEventEnum _$sseEventEventEnum_sessionRevoked =
    const SseEventEventEnum._('sessionRevoked');
const SseEventEventEnum _$sseEventEventEnum_campEnded =
    const SseEventEventEnum._('campEnded');
const SseEventEventEnum _$sseEventEventEnum_deviceRegistrationUpdated =
    const SseEventEventEnum._('deviceRegistrationUpdated');
const SseEventEventEnum _$sseEventEventEnum_lockoutAlert =
    const SseEventEventEnum._('lockoutAlert');

SseEventEventEnum _$sseEventEventEnumValueOf(String name) {
  switch (name) {
    case 'tracksUpdated':
      return _$sseEventEventEnum_tracksUpdated;
    case 'trackUpdated':
      return _$sseEventEventEnum_trackUpdated;
    case 'cornersUpdated':
      return _$sseEventEventEnum_cornersUpdated;
    case 'groupsUpdated':
      return _$sseEventEventEnum_groupsUpdated;
    case 'campUpdated':
      return _$sseEventEventEnum_campUpdated;
    case 'messagesChanged':
      return _$sseEventEventEnum_messagesChanged;
    case 'trackDeleted':
      return _$sseEventEventEnum_trackDeleted;
    case 'sessionRevoked':
      return _$sseEventEventEnum_sessionRevoked;
    case 'campEnded':
      return _$sseEventEventEnum_campEnded;
    case 'deviceRegistrationUpdated':
      return _$sseEventEventEnum_deviceRegistrationUpdated;
    case 'lockoutAlert':
      return _$sseEventEventEnum_lockoutAlert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SseEventEventEnum> _$sseEventEventEnumValues =
    BuiltSet<SseEventEventEnum>(const <SseEventEventEnum>[
      _$sseEventEventEnum_tracksUpdated,
      _$sseEventEventEnum_trackUpdated,
      _$sseEventEventEnum_cornersUpdated,
      _$sseEventEventEnum_groupsUpdated,
      _$sseEventEventEnum_campUpdated,
      _$sseEventEventEnum_messagesChanged,
      _$sseEventEventEnum_trackDeleted,
      _$sseEventEventEnum_sessionRevoked,
      _$sseEventEventEnum_campEnded,
      _$sseEventEventEnum_deviceRegistrationUpdated,
      _$sseEventEventEnum_lockoutAlert,
    ]);

Serializer<SseEventEventEnum> _$sseEventEventEnumSerializer =
    _$SseEventEventEnumSerializer();

class _$SseEventEventEnumSerializer
    implements PrimitiveSerializer<SseEventEventEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'tracksUpdated': 'tracks_updated',
    'trackUpdated': 'track_updated',
    'cornersUpdated': 'corners_updated',
    'groupsUpdated': 'groups_updated',
    'campUpdated': 'camp_updated',
    'messagesChanged': 'messages_changed',
    'trackDeleted': 'track_deleted',
    'sessionRevoked': 'session_revoked',
    'campEnded': 'camp_ended',
    'deviceRegistrationUpdated': 'device_registration_updated',
    'lockoutAlert': 'lockout_alert',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'tracks_updated': 'tracksUpdated',
    'track_updated': 'trackUpdated',
    'corners_updated': 'cornersUpdated',
    'groups_updated': 'groupsUpdated',
    'camp_updated': 'campUpdated',
    'messages_changed': 'messagesChanged',
    'track_deleted': 'trackDeleted',
    'session_revoked': 'sessionRevoked',
    'camp_ended': 'campEnded',
    'device_registration_updated': 'deviceRegistrationUpdated',
    'lockout_alert': 'lockoutAlert',
  };

  @override
  final Iterable<Type> types = const <Type>[SseEventEventEnum];
  @override
  final String wireName = 'SseEventEventEnum';

  @override
  Object serialize(
    Serializers serializers,
    SseEventEventEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SseEventEventEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SseEventEventEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SseEvent extends SseEvent {
  @override
  final SseEventEventEnum? event;
  @override
  final SseNotificationData? data;

  factory _$SseEvent([void Function(SseEventBuilder)? updates]) =>
      (SseEventBuilder()..update(updates))._build();

  _$SseEvent._({this.event, this.data}) : super._();
  @override
  SseEvent rebuild(void Function(SseEventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SseEventBuilder toBuilder() => SseEventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SseEvent && event == other.event && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, event.hashCode);
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SseEvent')
          ..add('event', event)
          ..add('data', data))
        .toString();
  }
}

class SseEventBuilder implements Builder<SseEvent, SseEventBuilder> {
  _$SseEvent? _$v;

  SseEventEventEnum? _event;
  SseEventEventEnum? get event => _$this._event;
  set event(SseEventEventEnum? event) => _$this._event = event;

  SseNotificationDataBuilder? _data;
  SseNotificationDataBuilder get data =>
      _$this._data ??= SseNotificationDataBuilder();
  set data(SseNotificationDataBuilder? data) => _$this._data = data;

  SseEventBuilder() {
    SseEvent._defaults(this);
  }

  SseEventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _event = $v.event;
      _data = $v.data?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SseEvent other) {
    _$v = other as _$SseEvent;
  }

  @override
  void update(void Function(SseEventBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SseEvent build() => _build();

  _$SseEvent _build() {
    _$SseEvent _$result;
    try {
      _$result = _$v ?? _$SseEvent._(event: event, data: _data?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SseEvent',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
