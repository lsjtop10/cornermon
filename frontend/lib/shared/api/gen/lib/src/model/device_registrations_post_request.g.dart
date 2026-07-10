// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_registrations_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeviceRegistrationsPostRequest extends DeviceRegistrationsPostRequest {
  @override
  final String registrationCode;
  @override
  final String deviceName;

  factory _$DeviceRegistrationsPostRequest([
    void Function(DeviceRegistrationsPostRequestBuilder)? updates,
  ]) => (DeviceRegistrationsPostRequestBuilder()..update(updates))._build();

  _$DeviceRegistrationsPostRequest._({
    required this.registrationCode,
    required this.deviceName,
  }) : super._();
  @override
  DeviceRegistrationsPostRequest rebuild(
    void Function(DeviceRegistrationsPostRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DeviceRegistrationsPostRequestBuilder toBuilder() =>
      DeviceRegistrationsPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceRegistrationsPostRequest &&
        registrationCode == other.registrationCode &&
        deviceName == other.deviceName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, registrationCode.hashCode);
    _$hash = $jc(_$hash, deviceName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceRegistrationsPostRequest')
          ..add('registrationCode', registrationCode)
          ..add('deviceName', deviceName))
        .toString();
  }
}

class DeviceRegistrationsPostRequestBuilder
    implements
        Builder<
          DeviceRegistrationsPostRequest,
          DeviceRegistrationsPostRequestBuilder
        > {
  _$DeviceRegistrationsPostRequest? _$v;

  String? _registrationCode;
  String? get registrationCode => _$this._registrationCode;
  set registrationCode(String? registrationCode) =>
      _$this._registrationCode = registrationCode;

  String? _deviceName;
  String? get deviceName => _$this._deviceName;
  set deviceName(String? deviceName) => _$this._deviceName = deviceName;

  DeviceRegistrationsPostRequestBuilder() {
    DeviceRegistrationsPostRequest._defaults(this);
  }

  DeviceRegistrationsPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _registrationCode = $v.registrationCode;
      _deviceName = $v.deviceName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceRegistrationsPostRequest other) {
    _$v = other as _$DeviceRegistrationsPostRequest;
  }

  @override
  void update(void Function(DeviceRegistrationsPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceRegistrationsPostRequest build() => _build();

  _$DeviceRegistrationsPostRequest _build() {
    final _$result =
        _$v ??
        _$DeviceRegistrationsPostRequest._(
          registrationCode: BuiltValueNullFieldError.checkNotNull(
            registrationCode,
            r'DeviceRegistrationsPostRequest',
            'registrationCode',
          ),
          deviceName: BuiltValueNullFieldError.checkNotNull(
            deviceName,
            r'DeviceRegistrationsPostRequest',
            'deviceName',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
