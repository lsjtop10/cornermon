// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_operational_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TrackOperationalStatus _$IDLE = const TrackOperationalStatus._('IDLE');
const TrackOperationalStatus _$BUSY = const TrackOperationalStatus._('BUSY');

TrackOperationalStatus _$valueOf(String name) {
  switch (name) {
    case 'IDLE':
      return _$IDLE;
    case 'BUSY':
      return _$BUSY;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TrackOperationalStatus> _$values =
    BuiltSet<TrackOperationalStatus>(const <TrackOperationalStatus>[
      _$IDLE,
      _$BUSY,
    ]);

class _$TrackOperationalStatusMeta {
  const _$TrackOperationalStatusMeta();
  TrackOperationalStatus get IDLE => _$IDLE;
  TrackOperationalStatus get BUSY => _$BUSY;
  TrackOperationalStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<TrackOperationalStatus> get values => _$values;
}

mixin _$TrackOperationalStatusMixin {
  // ignore: non_constant_identifier_names
  _$TrackOperationalStatusMeta get TrackOperationalStatus =>
      const _$TrackOperationalStatusMeta();
}

Serializer<TrackOperationalStatus> _$trackOperationalStatusSerializer =
    _$TrackOperationalStatusSerializer();

class _$TrackOperationalStatusSerializer
    implements PrimitiveSerializer<TrackOperationalStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'IDLE': 'IDLE',
    'BUSY': 'BUSY',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'IDLE': 'IDLE',
    'BUSY': 'BUSY',
  };

  @override
  final Iterable<Type> types = const <Type>[TrackOperationalStatus];
  @override
  final String wireName = 'TrackOperationalStatus';

  @override
  Object serialize(
    Serializers serializers,
    TrackOperationalStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  TrackOperationalStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => TrackOperationalStatus.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
