// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corner_operational_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CornerOperationalStatus _$INACTIVE =
    const CornerOperationalStatus._('INACTIVE');
const CornerOperationalStatus _$IDLE = const CornerOperationalStatus._('IDLE');
const CornerOperationalStatus _$BUSY = const CornerOperationalStatus._('BUSY');

CornerOperationalStatus _$valueOf(String name) {
  switch (name) {
    case 'INACTIVE':
      return _$INACTIVE;
    case 'IDLE':
      return _$IDLE;
    case 'BUSY':
      return _$BUSY;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CornerOperationalStatus> _$values =
    BuiltSet<CornerOperationalStatus>(const <CornerOperationalStatus>[
  _$INACTIVE,
  _$IDLE,
  _$BUSY,
]);

class _$CornerOperationalStatusMeta {
  const _$CornerOperationalStatusMeta();
  CornerOperationalStatus get INACTIVE => _$INACTIVE;
  CornerOperationalStatus get IDLE => _$IDLE;
  CornerOperationalStatus get BUSY => _$BUSY;
  CornerOperationalStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<CornerOperationalStatus> get values => _$values;
}

abstract class _$CornerOperationalStatusMixin {
  // ignore: non_constant_identifier_names
  _$CornerOperationalStatusMeta get CornerOperationalStatus =>
      const _$CornerOperationalStatusMeta();
}

Serializer<CornerOperationalStatus> _$cornerOperationalStatusSerializer =
    _$CornerOperationalStatusSerializer();

class _$CornerOperationalStatusSerializer
    implements PrimitiveSerializer<CornerOperationalStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'INACTIVE': 'INACTIVE',
    'IDLE': 'IDLE',
    'BUSY': 'BUSY',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'INACTIVE': 'INACTIVE',
    'IDLE': 'IDLE',
    'BUSY': 'BUSY',
  };

  @override
  final Iterable<Type> types = const <Type>[CornerOperationalStatus];
  @override
  final String wireName = 'CornerOperationalStatus';

  @override
  Object serialize(Serializers serializers, CornerOperationalStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CornerOperationalStatus deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CornerOperationalStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
