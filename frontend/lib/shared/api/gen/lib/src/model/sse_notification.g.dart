// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'sse_notification.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SSENotificationEventEnum _$sSENotificationEventEnum_tracksUpdated =
    const SSENotificationEventEnum._('tracksUpdated');
const SSENotificationEventEnum _$sSENotificationEventEnum_trackUpdated =
    const SSENotificationEventEnum._('trackUpdated');
const SSENotificationEventEnum _$sSENotificationEventEnum_cornersUpdated =
    const SSENotificationEventEnum._('cornersUpdated');
const SSENotificationEventEnum _$sSENotificationEventEnum_groupsUpdated =
    const SSENotificationEventEnum._('groupsUpdated');
const SSENotificationEventEnum _$sSENotificationEventEnum_campUpdated =
    const SSENotificationEventEnum._('campUpdated');
const SSENotificationEventEnum _$sSENotificationEventEnum_messagesChanged =
    const SSENotificationEventEnum._('messagesChanged');
const SSENotificationEventEnum _$sSENotificationEventEnum_trackDeleted =
    const SSENotificationEventEnum._('trackDeleted');
const SSENotificationEventEnum _$sSENotificationEventEnum_trackReplaced =
    const SSENotificationEventEnum._('trackReplaced');
const SSENotificationEventEnum _$sSENotificationEventEnum_sessionRevoked =
    const SSENotificationEventEnum._('sessionRevoked');
const SSENotificationEventEnum _$sSENotificationEventEnum_campEnded =
    const SSENotificationEventEnum._('campEnded');
const SSENotificationEventEnum
    _$sSENotificationEventEnum_deviceRegistrationUpdated =
    const SSENotificationEventEnum._('deviceRegistrationUpdated');
const SSENotificationEventEnum _$sSENotificationEventEnum_lockoutAlert =
    const SSENotificationEventEnum._('lockoutAlert');

SSENotificationEventEnum _$sSENotificationEventEnumValueOf(String name) {
  switch (name) {
    case 'tracksUpdated':
      return _$sSENotificationEventEnum_tracksUpdated;
    case 'trackUpdated':
      return _$sSENotificationEventEnum_trackUpdated;
    case 'cornersUpdated':
      return _$sSENotificationEventEnum_cornersUpdated;
    case 'groupsUpdated':
      return _$sSENotificationEventEnum_groupsUpdated;
    case 'campUpdated':
      return _$sSENotificationEventEnum_campUpdated;
    case 'messagesChanged':
      return _$sSENotificationEventEnum_messagesChanged;
    case 'trackDeleted':
      return _$sSENotificationEventEnum_trackDeleted;
    case 'trackReplaced':
      return _$sSENotificationEventEnum_trackReplaced;
    case 'sessionRevoked':
      return _$sSENotificationEventEnum_sessionRevoked;
    case 'campEnded':
      return _$sSENotificationEventEnum_campEnded;
    case 'deviceRegistrationUpdated':
      return _$sSENotificationEventEnum_deviceRegistrationUpdated;
    case 'lockoutAlert':
      return _$sSENotificationEventEnum_lockoutAlert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SSENotificationEventEnum> _$sSENotificationEventEnumValues =
    BuiltSet<SSENotificationEventEnum>(const <SSENotificationEventEnum>[
  _$sSENotificationEventEnum_tracksUpdated,
  _$sSENotificationEventEnum_trackUpdated,
  _$sSENotificationEventEnum_cornersUpdated,
  _$sSENotificationEventEnum_groupsUpdated,
  _$sSENotificationEventEnum_campUpdated,
  _$sSENotificationEventEnum_messagesChanged,
  _$sSENotificationEventEnum_trackDeleted,
  _$sSENotificationEventEnum_trackReplaced,
  _$sSENotificationEventEnum_sessionRevoked,
  _$sSENotificationEventEnum_campEnded,
  _$sSENotificationEventEnum_deviceRegistrationUpdated,
  _$sSENotificationEventEnum_lockoutAlert,
]);

Serializer<SSENotificationEventEnum> _$sSENotificationEventEnumSerializer =
    _$SSENotificationEventEnumSerializer();

class _$SSENotificationEventEnumSerializer
    implements PrimitiveSerializer<SSENotificationEventEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'tracksUpdated': 'tracks_updated',
    'trackUpdated': 'track_updated',
    'cornersUpdated': 'corners_updated',
    'groupsUpdated': 'groups_updated',
    'campUpdated': 'camp_updated',
    'messagesChanged': 'messages_changed',
    'trackDeleted': 'track_deleted',
    'trackReplaced': 'track_replaced',
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
    'track_replaced': 'trackReplaced',
    'session_revoked': 'sessionRevoked',
    'camp_ended': 'campEnded',
    'device_registration_updated': 'deviceRegistrationUpdated',
    'lockout_alert': 'lockoutAlert',
  };

  @override
  final Iterable<Type> types = const <Type>[SSENotificationEventEnum];
  @override
  final String wireName = 'SSENotificationEventEnum';

  @override
  Object serialize(Serializers serializers, SSENotificationEventEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SSENotificationEventEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SSENotificationEventEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$SSENotification extends SSENotification {
  @override
  final SSENotificationEventEnum? event;
  @override
  final SSEScope? scope;

  factory _$SSENotification([void Function(SSENotificationBuilder)? updates]) =>
      (SSENotificationBuilder()..update(updates))._build();

  _$SSENotification._({this.event, this.scope}) : super._();
  @override
  SSENotification rebuild(void Function(SSENotificationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SSENotificationBuilder toBuilder() => SSENotificationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SSENotification &&
        event == other.event &&
        scope == other.scope;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, event.hashCode);
    _$hash = $jc(_$hash, scope.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SSENotification')
          ..add('event', event)
          ..add('scope', scope))
        .toString();
  }
}

class SSENotificationBuilder
    implements Builder<SSENotification, SSENotificationBuilder> {
  _$SSENotification? _$v;

  SSENotificationEventEnum? _event;
  SSENotificationEventEnum? get event => _$this._event;
  set event(SSENotificationEventEnum? event) => _$this._event = event;

  SSEScopeBuilder? _scope;
  SSEScopeBuilder get scope => _$this._scope ??= SSEScopeBuilder();
  set scope(SSEScopeBuilder? scope) => _$this._scope = scope;

  SSENotificationBuilder() {
    SSENotification._defaults(this);
  }

  SSENotificationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _event = $v.event;
      _scope = $v.scope?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SSENotification other) {
    _$v = other as _$SSENotification;
  }

  @override
  void update(void Function(SSENotificationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SSENotification build() => _build();

  _$SSENotification _build() {
    _$SSENotification _$result;
    try {
      _$result = _$v ??
          _$SSENotification._(
            event: event,
            scope: _scope?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'scope';
        _scope?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SSENotification', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
