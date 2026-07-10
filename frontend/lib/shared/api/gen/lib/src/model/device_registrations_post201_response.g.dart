// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_registrations_post201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeviceRegistrationsPost201Response
    extends DeviceRegistrationsPost201Response {
  @override
  final DeviceRegistration? deviceRegistration;
  @override
  final String? deviceToken;

  factory _$DeviceRegistrationsPost201Response([
    void Function(DeviceRegistrationsPost201ResponseBuilder)? updates,
  ]) => (DeviceRegistrationsPost201ResponseBuilder()..update(updates))._build();

  _$DeviceRegistrationsPost201Response._({
    this.deviceRegistration,
    this.deviceToken,
  }) : super._();
  @override
  DeviceRegistrationsPost201Response rebuild(
    void Function(DeviceRegistrationsPost201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DeviceRegistrationsPost201ResponseBuilder toBuilder() =>
      DeviceRegistrationsPost201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceRegistrationsPost201Response &&
        deviceRegistration == other.deviceRegistration &&
        deviceToken == other.deviceToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, deviceRegistration.hashCode);
    _$hash = $jc(_$hash, deviceToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceRegistrationsPost201Response')
          ..add('deviceRegistration', deviceRegistration)
          ..add('deviceToken', deviceToken))
        .toString();
  }
}

class DeviceRegistrationsPost201ResponseBuilder
    implements
        Builder<
          DeviceRegistrationsPost201Response,
          DeviceRegistrationsPost201ResponseBuilder
        > {
  _$DeviceRegistrationsPost201Response? _$v;

  DeviceRegistrationBuilder? _deviceRegistration;
  DeviceRegistrationBuilder get deviceRegistration =>
      _$this._deviceRegistration ??= DeviceRegistrationBuilder();
  set deviceRegistration(DeviceRegistrationBuilder? deviceRegistration) =>
      _$this._deviceRegistration = deviceRegistration;

  String? _deviceToken;
  String? get deviceToken => _$this._deviceToken;
  set deviceToken(String? deviceToken) => _$this._deviceToken = deviceToken;

  DeviceRegistrationsPost201ResponseBuilder() {
    DeviceRegistrationsPost201Response._defaults(this);
  }

  DeviceRegistrationsPost201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _deviceRegistration = $v.deviceRegistration?.toBuilder();
      _deviceToken = $v.deviceToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceRegistrationsPost201Response other) {
    _$v = other as _$DeviceRegistrationsPost201Response;
  }

  @override
  void update(
    void Function(DeviceRegistrationsPost201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  DeviceRegistrationsPost201Response build() => _build();

  _$DeviceRegistrationsPost201Response _build() {
    _$DeviceRegistrationsPost201Response _$result;
    try {
      _$result =
          _$v ??
          _$DeviceRegistrationsPost201Response._(
            deviceRegistration: _deviceRegistration?.build(),
            deviceToken: deviceToken,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'deviceRegistration';
        _deviceRegistration?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DeviceRegistrationsPost201Response',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
