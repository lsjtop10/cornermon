// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_registration_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DeviceRegistrationStatus _$PENDING =
    const DeviceRegistrationStatus._('PENDING');
const DeviceRegistrationStatus _$APPROVED =
    const DeviceRegistrationStatus._('APPROVED');
const DeviceRegistrationStatus _$REJECTED =
    const DeviceRegistrationStatus._('REJECTED');
const DeviceRegistrationStatus _$REVOKED =
    const DeviceRegistrationStatus._('REVOKED');

DeviceRegistrationStatus _$valueOf(String name) {
  switch (name) {
    case 'PENDING':
      return _$PENDING;
    case 'APPROVED':
      return _$APPROVED;
    case 'REJECTED':
      return _$REJECTED;
    case 'REVOKED':
      return _$REVOKED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DeviceRegistrationStatus> _$values =
    BuiltSet<DeviceRegistrationStatus>(const <DeviceRegistrationStatus>[
  _$PENDING,
  _$APPROVED,
  _$REJECTED,
  _$REVOKED,
]);

class _$DeviceRegistrationStatusMeta {
  const _$DeviceRegistrationStatusMeta();
  DeviceRegistrationStatus get PENDING => _$PENDING;
  DeviceRegistrationStatus get APPROVED => _$APPROVED;
  DeviceRegistrationStatus get REJECTED => _$REJECTED;
  DeviceRegistrationStatus get REVOKED => _$REVOKED;
  DeviceRegistrationStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<DeviceRegistrationStatus> get values => _$values;
}

abstract class _$DeviceRegistrationStatusMixin {
  // ignore: non_constant_identifier_names
  _$DeviceRegistrationStatusMeta get DeviceRegistrationStatus =>
      const _$DeviceRegistrationStatusMeta();
}

Serializer<DeviceRegistrationStatus> _$deviceRegistrationStatusSerializer =
    _$DeviceRegistrationStatusSerializer();

class _$DeviceRegistrationStatusSerializer
    implements PrimitiveSerializer<DeviceRegistrationStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PENDING': 'PENDING',
    'APPROVED': 'APPROVED',
    'REJECTED': 'REJECTED',
    'REVOKED': 'REVOKED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PENDING': 'PENDING',
    'APPROVED': 'APPROVED',
    'REJECTED': 'REJECTED',
    'REVOKED': 'REVOKED',
  };

  @override
  final Iterable<Type> types = const <Type>[DeviceRegistrationStatus];
  @override
  final String wireName = 'DeviceRegistrationStatus';

  @override
  Object serialize(Serializers serializers, DeviceRegistrationStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DeviceRegistrationStatus deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DeviceRegistrationStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
