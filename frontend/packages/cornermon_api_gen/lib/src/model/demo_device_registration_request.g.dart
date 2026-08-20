// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demo_device_registration_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DemoDeviceRegistrationRequest extends DemoDeviceRegistrationRequest {
  @override
  final String? deviceModel;
  @override
  final String? deviceName;
  @override
  final String? displayName;

  factory _$DemoDeviceRegistrationRequest(
          [void Function(DemoDeviceRegistrationRequestBuilder)? updates]) =>
      (DemoDeviceRegistrationRequestBuilder()..update(updates))._build();

  _$DemoDeviceRegistrationRequest._(
      {this.deviceModel, this.deviceName, this.displayName})
      : super._();
  @override
  DemoDeviceRegistrationRequest rebuild(
          void Function(DemoDeviceRegistrationRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DemoDeviceRegistrationRequestBuilder toBuilder() =>
      DemoDeviceRegistrationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DemoDeviceRegistrationRequest &&
        deviceModel == other.deviceModel &&
        deviceName == other.deviceName &&
        displayName == other.displayName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, deviceModel.hashCode);
    _$hash = $jc(_$hash, deviceName.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DemoDeviceRegistrationRequest')
          ..add('deviceModel', deviceModel)
          ..add('deviceName', deviceName)
          ..add('displayName', displayName))
        .toString();
  }
}

class DemoDeviceRegistrationRequestBuilder
    implements
        Builder<DemoDeviceRegistrationRequest,
            DemoDeviceRegistrationRequestBuilder> {
  _$DemoDeviceRegistrationRequest? _$v;

  String? _deviceModel;
  String? get deviceModel => _$this._deviceModel;
  set deviceModel(String? deviceModel) => _$this._deviceModel = deviceModel;

  String? _deviceName;
  String? get deviceName => _$this._deviceName;
  set deviceName(String? deviceName) => _$this._deviceName = deviceName;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  DemoDeviceRegistrationRequestBuilder() {
    DemoDeviceRegistrationRequest._defaults(this);
  }

  DemoDeviceRegistrationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _deviceModel = $v.deviceModel;
      _deviceName = $v.deviceName;
      _displayName = $v.displayName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DemoDeviceRegistrationRequest other) {
    _$v = other as _$DemoDeviceRegistrationRequest;
  }

  @override
  void update(void Function(DemoDeviceRegistrationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DemoDeviceRegistrationRequest build() => _build();

  _$DemoDeviceRegistrationRequest _build() {
    final _$result = _$v ??
        _$DemoDeviceRegistrationRequest._(
          deviceModel: deviceModel,
          deviceName: deviceName,
          displayName: displayName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
