// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

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
  final String? deviceModel;
  @override
  final String? deviceName;
  @override
  final String? displayName;
  @override
  final String? registrationCode;
  @override
  final DeviceRegistrationRequestRoleEnum? role;

  factory _$DeviceRegistrationRequest(
          [void Function(DeviceRegistrationRequestBuilder)? updates]) =>
      (DeviceRegistrationRequestBuilder()..update(updates))._build();

  _$DeviceRegistrationRequest._(
      {this.deviceModel,
      this.deviceName,
      this.displayName,
      this.registrationCode,
      this.role})
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
        deviceModel == other.deviceModel &&
        deviceName == other.deviceName &&
        displayName == other.displayName &&
        registrationCode == other.registrationCode &&
        role == other.role;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, deviceModel.hashCode);
    _$hash = $jc(_$hash, deviceName.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, registrationCode.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceRegistrationRequest')
          ..add('deviceModel', deviceModel)
          ..add('deviceName', deviceName)
          ..add('displayName', displayName)
          ..add('registrationCode', registrationCode)
          ..add('role', role))
        .toString();
  }
}

class DeviceRegistrationRequestBuilder
    implements
        Builder<DeviceRegistrationRequest, DeviceRegistrationRequestBuilder> {
  _$DeviceRegistrationRequest? _$v;

  String? _deviceModel;
  String? get deviceModel => _$this._deviceModel;
  set deviceModel(String? deviceModel) => _$this._deviceModel = deviceModel;

  String? _deviceName;
  String? get deviceName => _$this._deviceName;
  set deviceName(String? deviceName) => _$this._deviceName = deviceName;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _registrationCode;
  String? get registrationCode => _$this._registrationCode;
  set registrationCode(String? registrationCode) =>
      _$this._registrationCode = registrationCode;

  DeviceRegistrationRequestRoleEnum? _role;
  DeviceRegistrationRequestRoleEnum? get role => _$this._role;
  set role(DeviceRegistrationRequestRoleEnum? role) => _$this._role = role;

  DeviceRegistrationRequestBuilder() {
    DeviceRegistrationRequest._defaults(this);
  }

  DeviceRegistrationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _deviceModel = $v.deviceModel;
      _deviceName = $v.deviceName;
      _displayName = $v.displayName;
      _registrationCode = $v.registrationCode;
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
          deviceModel: deviceModel,
          deviceName: deviceName,
          displayName: displayName,
          registrationCode: registrationCode,
          role: role,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
