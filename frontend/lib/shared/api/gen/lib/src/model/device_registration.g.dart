// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_registration.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeviceRegistration extends DeviceRegistration {
  @override
  final String id;
  @override
  final String deviceName;
  @override
  final DeviceRegistrationStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime? approvedAt;

  factory _$DeviceRegistration([
    void Function(DeviceRegistrationBuilder)? updates,
  ]) => (DeviceRegistrationBuilder()..update(updates))._build();

  _$DeviceRegistration._({
    required this.id,
    required this.deviceName,
    required this.status,
    required this.createdAt,
    this.approvedAt,
  }) : super._();
  @override
  DeviceRegistration rebuild(
    void Function(DeviceRegistrationBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DeviceRegistrationBuilder toBuilder() =>
      DeviceRegistrationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceRegistration &&
        id == other.id &&
        deviceName == other.deviceName &&
        status == other.status &&
        createdAt == other.createdAt &&
        approvedAt == other.approvedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, deviceName.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, approvedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceRegistration')
          ..add('id', id)
          ..add('deviceName', deviceName)
          ..add('status', status)
          ..add('createdAt', createdAt)
          ..add('approvedAt', approvedAt))
        .toString();
  }
}

class DeviceRegistrationBuilder
    implements Builder<DeviceRegistration, DeviceRegistrationBuilder> {
  _$DeviceRegistration? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _deviceName;
  String? get deviceName => _$this._deviceName;
  set deviceName(String? deviceName) => _$this._deviceName = deviceName;

  DeviceRegistrationStatus? _status;
  DeviceRegistrationStatus? get status => _$this._status;
  set status(DeviceRegistrationStatus? status) => _$this._status = status;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _approvedAt;
  DateTime? get approvedAt => _$this._approvedAt;
  set approvedAt(DateTime? approvedAt) => _$this._approvedAt = approvedAt;

  DeviceRegistrationBuilder() {
    DeviceRegistration._defaults(this);
  }

  DeviceRegistrationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _deviceName = $v.deviceName;
      _status = $v.status;
      _createdAt = $v.createdAt;
      _approvedAt = $v.approvedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceRegistration other) {
    _$v = other as _$DeviceRegistration;
  }

  @override
  void update(void Function(DeviceRegistrationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceRegistration build() => _build();

  _$DeviceRegistration _build() {
    final _$result =
        _$v ??
        _$DeviceRegistration._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'DeviceRegistration',
            'id',
          ),
          deviceName: BuiltValueNullFieldError.checkNotNull(
            deviceName,
            r'DeviceRegistration',
            'deviceName',
          ),
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'DeviceRegistration',
            'status',
          ),
          createdAt: BuiltValueNullFieldError.checkNotNull(
            createdAt,
            r'DeviceRegistration',
            'createdAt',
          ),
          approvedAt: approvedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
