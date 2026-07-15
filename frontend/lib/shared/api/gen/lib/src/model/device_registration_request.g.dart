// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_registration_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DeviceRegistrationRequestRoleEnum
    _$deviceRegistrationRequestRoleEnum_ADMIN =
    const DeviceRegistrationRequestRoleEnum._('ADMIN');
const DeviceRegistrationRequestRoleEnum
    _$deviceRegistrationRequestRoleEnum_FACILITATOR =
    const DeviceRegistrationRequestRoleEnum._('FACILITATOR');

DeviceRegistrationRequestRoleEnum _$deviceRegistrationRequestRoleEnumValueOf(
    String name) {
  switch (name) {
    case 'ADMIN':
      return _$deviceRegistrationRequestRoleEnum_ADMIN;
    case 'FACILITATOR':
      return _$deviceRegistrationRequestRoleEnum_FACILITATOR;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DeviceRegistrationRequestRoleEnum>
    _$deviceRegistrationRequestRoleEnumValues = BuiltSet<
        DeviceRegistrationRequestRoleEnum>(const <DeviceRegistrationRequestRoleEnum>[
  _$deviceRegistrationRequestRoleEnum_ADMIN,
  _$deviceRegistrationRequestRoleEnum_FACILITATOR,
]);

Serializer<DeviceRegistrationRequestRoleEnum>
    _$deviceRegistrationRequestRoleEnumSerializer =
    _$DeviceRegistrationRequestRoleEnumSerializer();

class _$DeviceRegistrationRequestRoleEnumSerializer
    implements PrimitiveSerializer<DeviceRegistrationRequestRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ADMIN': 'ADMIN',
    'FACILITATOR': 'FACILITATOR',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ADMIN': 'ADMIN',
    'FACILITATOR': 'FACILITATOR',
  };

  @override
  final Iterable<Type> types = const <Type>[DeviceRegistrationRequestRoleEnum];
  @override
  final String wireName = 'DeviceRegistrationRequestRoleEnum';

  @override
  Object serialize(
          Serializers serializers, DeviceRegistrationRequestRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DeviceRegistrationRequestRoleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DeviceRegistrationRequestRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DeviceRegistrationRequest extends DeviceRegistrationRequest {
  @override
  final String? campId;
  @override
  final String? deviceName;
  @override
  final DeviceRegistrationRequestRoleEnum? role;

  factory _$DeviceRegistrationRequest(
          [void Function(DeviceRegistrationRequestBuilder)? updates]) =>
      (DeviceRegistrationRequestBuilder()..update(updates))._build();

  _$DeviceRegistrationRequest._({this.campId, this.deviceName, this.role})
      : super._();
  @override
  DeviceRegistrationRequest rebuild(
          void Function(DeviceRegistrationRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceRegistrationRequestBuilder toBuilder() =>
      DeviceRegistrationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceRegistrationRequest &&
        campId == other.campId &&
        deviceName == other.deviceName &&
        role == other.role;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, campId.hashCode);
    _$hash = $jc(_$hash, deviceName.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceRegistrationRequest')
          ..add('campId', campId)
          ..add('deviceName', deviceName)
          ..add('role', role))
        .toString();
  }
}

class DeviceRegistrationRequestBuilder
    implements
        Builder<DeviceRegistrationRequest, DeviceRegistrationRequestBuilder> {
  _$DeviceRegistrationRequest? _$v;

  String? _campId;
  String? get campId => _$this._campId;
  set campId(String? campId) => _$this._campId = campId;

  String? _deviceName;
  String? get deviceName => _$this._deviceName;
  set deviceName(String? deviceName) => _$this._deviceName = deviceName;

  DeviceRegistrationRequestRoleEnum? _role;
  DeviceRegistrationRequestRoleEnum? get role => _$this._role;
  set role(DeviceRegistrationRequestRoleEnum? role) => _$this._role = role;

  DeviceRegistrationRequestBuilder() {
    DeviceRegistrationRequest._defaults(this);
  }

  DeviceRegistrationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _campId = $v.campId;
      _deviceName = $v.deviceName;
      _role = $v.role;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceRegistrationRequest other) {
    _$v = other as _$DeviceRegistrationRequest;
  }

  @override
  void update(void Function(DeviceRegistrationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceRegistrationRequest build() => _build();

  _$DeviceRegistrationRequest _build() {
    final _$result = _$v ??
        _$DeviceRegistrationRequest._(
          campId: campId,
          deviceName: deviceName,
          role: role,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
