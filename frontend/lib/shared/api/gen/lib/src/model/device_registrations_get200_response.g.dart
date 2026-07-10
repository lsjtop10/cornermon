// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_registrations_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeviceRegistrationsGet200Response
    extends DeviceRegistrationsGet200Response {
  @override
  final BuiltList<DeviceRegistration>? deviceRegistrations;

  factory _$DeviceRegistrationsGet200Response([
    void Function(DeviceRegistrationsGet200ResponseBuilder)? updates,
  ]) => (DeviceRegistrationsGet200ResponseBuilder()..update(updates))._build();

  _$DeviceRegistrationsGet200Response._({this.deviceRegistrations}) : super._();
  @override
  DeviceRegistrationsGet200Response rebuild(
    void Function(DeviceRegistrationsGet200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DeviceRegistrationsGet200ResponseBuilder toBuilder() =>
      DeviceRegistrationsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceRegistrationsGet200Response &&
        deviceRegistrations == other.deviceRegistrations;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, deviceRegistrations.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'DeviceRegistrationsGet200Response',
    )..add('deviceRegistrations', deviceRegistrations)).toString();
  }
}

class DeviceRegistrationsGet200ResponseBuilder
    implements
        Builder<
          DeviceRegistrationsGet200Response,
          DeviceRegistrationsGet200ResponseBuilder
        > {
  _$DeviceRegistrationsGet200Response? _$v;

  ListBuilder<DeviceRegistration>? _deviceRegistrations;
  ListBuilder<DeviceRegistration> get deviceRegistrations =>
      _$this._deviceRegistrations ??= ListBuilder<DeviceRegistration>();
  set deviceRegistrations(
    ListBuilder<DeviceRegistration>? deviceRegistrations,
  ) => _$this._deviceRegistrations = deviceRegistrations;

  DeviceRegistrationsGet200ResponseBuilder() {
    DeviceRegistrationsGet200Response._defaults(this);
  }

  DeviceRegistrationsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _deviceRegistrations = $v.deviceRegistrations?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceRegistrationsGet200Response other) {
    _$v = other as _$DeviceRegistrationsGet200Response;
  }

  @override
  void update(
    void Function(DeviceRegistrationsGet200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  DeviceRegistrationsGet200Response build() => _build();

  _$DeviceRegistrationsGet200Response _build() {
    _$DeviceRegistrationsGet200Response _$result;
    try {
      _$result =
          _$v ??
          _$DeviceRegistrationsGet200Response._(
            deviceRegistrations: _deviceRegistrations?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'deviceRegistrations';
        _deviceRegistrations?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DeviceRegistrationsGet200Response',
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
