// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sse_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SseEventEventEnum _$sseEventEventEnum_snapshot =
    const SseEventEventEnum._('snapshot');
const SseEventEventEnum _$sseEventEventEnum_visitPeriodStarted =
    const SseEventEventEnum._('visitPeriodStarted');
const SseEventEventEnum _$sseEventEventEnum_visitPeriodEnded =
    const SseEventEventEnum._('visitPeriodEnded');
const SseEventEventEnum _$sseEventEventEnum_trackPeriodCreated =
    const SseEventEventEnum._('trackPeriodCreated');
const SseEventEventEnum _$sseEventEventEnum_trackPeriodDeleted =
    const SseEventEventEnum._('trackPeriodDeleted');
const SseEventEventEnum _$sseEventEventEnum_trackPeriodReplaced =
    const SseEventEventEnum._('trackPeriodReplaced');
const SseEventEventEnum _$sseEventEventEnum_cornerPeriodUpdated =
    const SseEventEventEnum._('cornerPeriodUpdated');
const SseEventEventEnum _$sseEventEventEnum_campPeriodStarted =
    const SseEventEventEnum._('campPeriodStarted');
const SseEventEventEnum _$sseEventEventEnum_campPeriodEnded =
    const SseEventEventEnum._('campPeriodEnded');
const SseEventEventEnum _$sseEventEventEnum_messagePeriodBroadcast =
    const SseEventEventEnum._('messagePeriodBroadcast');
const SseEventEventEnum _$sseEventEventEnum_messagePeriodDirect =
    const SseEventEventEnum._('messagePeriodDirect');
const SseEventEventEnum _$sseEventEventEnum_sessionPeriodForceLogout =
    const SseEventEventEnum._('sessionPeriodForceLogout');
const SseEventEventEnum _$sseEventEventEnum_devicePeriodApproved =
    const SseEventEventEnum._('devicePeriodApproved');
const SseEventEventEnum _$sseEventEventEnum_lockoutPeriodAlert =
    const SseEventEventEnum._('lockoutPeriodAlert');

SseEventEventEnum _$sseEventEventEnumValueOf(String name) {
  switch (name) {
    case 'snapshot':
      return _$sseEventEventEnum_snapshot;
    case 'visitPeriodStarted':
      return _$sseEventEventEnum_visitPeriodStarted;
    case 'visitPeriodEnded':
      return _$sseEventEventEnum_visitPeriodEnded;
    case 'trackPeriodCreated':
      return _$sseEventEventEnum_trackPeriodCreated;
    case 'trackPeriodDeleted':
      return _$sseEventEventEnum_trackPeriodDeleted;
    case 'trackPeriodReplaced':
      return _$sseEventEventEnum_trackPeriodReplaced;
    case 'cornerPeriodUpdated':
      return _$sseEventEventEnum_cornerPeriodUpdated;
    case 'campPeriodStarted':
      return _$sseEventEventEnum_campPeriodStarted;
    case 'campPeriodEnded':
      return _$sseEventEventEnum_campPeriodEnded;
    case 'messagePeriodBroadcast':
      return _$sseEventEventEnum_messagePeriodBroadcast;
    case 'messagePeriodDirect':
      return _$sseEventEventEnum_messagePeriodDirect;
    case 'sessionPeriodForceLogout':
      return _$sseEventEventEnum_sessionPeriodForceLogout;
    case 'devicePeriodApproved':
      return _$sseEventEventEnum_devicePeriodApproved;
    case 'lockoutPeriodAlert':
      return _$sseEventEventEnum_lockoutPeriodAlert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SseEventEventEnum> _$sseEventEventEnumValues =
    BuiltSet<SseEventEventEnum>(const <SseEventEventEnum>[
      _$sseEventEventEnum_snapshot,
      _$sseEventEventEnum_visitPeriodStarted,
      _$sseEventEventEnum_visitPeriodEnded,
      _$sseEventEventEnum_trackPeriodCreated,
      _$sseEventEventEnum_trackPeriodDeleted,
      _$sseEventEventEnum_trackPeriodReplaced,
      _$sseEventEventEnum_cornerPeriodUpdated,
      _$sseEventEventEnum_campPeriodStarted,
      _$sseEventEventEnum_campPeriodEnded,
      _$sseEventEventEnum_messagePeriodBroadcast,
      _$sseEventEventEnum_messagePeriodDirect,
      _$sseEventEventEnum_sessionPeriodForceLogout,
      _$sseEventEventEnum_devicePeriodApproved,
      _$sseEventEventEnum_lockoutPeriodAlert,
    ]);

Serializer<SseEventEventEnum> _$sseEventEventEnumSerializer =
    _$SseEventEventEnumSerializer();

class _$SseEventEventEnumSerializer
    implements PrimitiveSerializer<SseEventEventEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'snapshot': 'snapshot',
    'visitPeriodStarted': 'visit.started',
    'visitPeriodEnded': 'visit.ended',
    'trackPeriodCreated': 'track.created',
    'trackPeriodDeleted': 'track.deleted',
    'trackPeriodReplaced': 'track.replaced',
    'cornerPeriodUpdated': 'corner.updated',
    'campPeriodStarted': 'camp.started',
    'campPeriodEnded': 'camp.ended',
    'messagePeriodBroadcast': 'message.broadcast',
    'messagePeriodDirect': 'message.direct',
    'sessionPeriodForceLogout': 'session.force_logout',
    'devicePeriodApproved': 'device.approved',
    'lockoutPeriodAlert': 'lockout.alert',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'snapshot': 'snapshot',
    'visit.started': 'visitPeriodStarted',
    'visit.ended': 'visitPeriodEnded',
    'track.created': 'trackPeriodCreated',
    'track.deleted': 'trackPeriodDeleted',
    'track.replaced': 'trackPeriodReplaced',
    'corner.updated': 'cornerPeriodUpdated',
    'camp.started': 'campPeriodStarted',
    'camp.ended': 'campPeriodEnded',
    'message.broadcast': 'messagePeriodBroadcast',
    'message.direct': 'messagePeriodDirect',
    'session.force_logout': 'sessionPeriodForceLogout',
    'device.approved': 'devicePeriodApproved',
    'lockout.alert': 'lockoutPeriodAlert',
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
  final JsonObject? data;

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

  JsonObject? _data;
  JsonObject? get data => _$this._data;
  set data(JsonObject? data) => _$this._data = data;

  SseEventBuilder() {
    SseEvent._defaults(this);
  }

  SseEventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _event = $v.event;
      _data = $v.data;
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
    final _$result = _$v ?? _$SseEvent._(event: event, data: data);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
