// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camp_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CampStatus _$PENDING = const CampStatus._('PENDING');
const CampStatus _$ACTIVE = const CampStatus._('ACTIVE');
const CampStatus _$ENDED = const CampStatus._('ENDED');

CampStatus _$valueOf(String name) {
  switch (name) {
    case 'PENDING':
      return _$PENDING;
    case 'ACTIVE':
      return _$ACTIVE;
    case 'ENDED':
      return _$ENDED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CampStatus> _$values = BuiltSet<CampStatus>(const <CampStatus>[
  _$PENDING,
  _$ACTIVE,
  _$ENDED,
]);

class _$CampStatusMeta {
  const _$CampStatusMeta();
  CampStatus get PENDING => _$PENDING;
  CampStatus get ACTIVE => _$ACTIVE;
  CampStatus get ENDED => _$ENDED;
  CampStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<CampStatus> get values => _$values;
}

mixin _$CampStatusMixin {
  // ignore: non_constant_identifier_names
  _$CampStatusMeta get CampStatus => const _$CampStatusMeta();
}

Serializer<CampStatus> _$campStatusSerializer = _$CampStatusSerializer();

class _$CampStatusSerializer implements PrimitiveSerializer<CampStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PENDING': 'PENDING',
    'ACTIVE': 'ACTIVE',
    'ENDED': 'ENDED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PENDING': 'PENDING',
    'ACTIVE': 'ACTIVE',
    'ENDED': 'ENDED',
  };

  @override
  final Iterable<Type> types = const <Type>[CampStatus];
  @override
  final String wireName = 'CampStatus';

  @override
  Object serialize(
    Serializers serializers,
    CampStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  CampStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => CampStatus.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
