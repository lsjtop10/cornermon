// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'device_registration_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DeviceRegistrationResponseStatusEnum
    _$deviceRegistrationResponseStatusEnum_PENDING =
    const DeviceRegistrationResponseStatusEnum._('PENDING');
const DeviceRegistrationResponseStatusEnum
    _$deviceRegistrationResponseStatusEnum_APPROVED =
    const DeviceRegistrationResponseStatusEnum._('APPROVED');
const DeviceRegistrationResponseStatusEnum
    _$deviceRegistrationResponseStatusEnum_REJECTED =
    const DeviceRegistrationResponseStatusEnum._('REJECTED');
const DeviceRegistrationResponseStatusEnum
    _$deviceRegistrationResponseStatusEnum_REVOKED =
    const DeviceRegistrationResponseStatusEnum._('REVOKED');

DeviceRegistrationResponseStatusEnum
    _$deviceRegistrationResponseStatusEnumValueOf(String name) {
  switch (name) {
    case 'PENDING':
      return _$deviceRegistrationResponseStatusEnum_PENDING;
    case 'APPROVED':
      return _$deviceRegistrationResponseStatusEnum_APPROVED;
    case 'REJECTED':
      return _$deviceRegistrationResponseStatusEnum_REJECTED;
    case 'REVOKED':
      return _$deviceRegistrationResponseStatusEnum_REVOKED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DeviceRegistrationResponseStatusEnum>
    _$deviceRegistrationResponseStatusEnumValues = BuiltSet<
        DeviceRegistrationResponseStatusEnum>(const <DeviceRegistrationResponseStatusEnum>[
  _$deviceRegistrationResponseStatusEnum_PENDING,
  _$deviceRegistrationResponseStatusEnum_APPROVED,
  _$deviceRegistrationResponseStatusEnum_REJECTED,
  _$deviceRegistrationResponseStatusEnum_REVOKED,
]);

Serializer<DeviceRegistrationResponseStatusEnum>
    _$deviceRegistrationResponseStatusEnumSerializer =
    _$DeviceRegistrationResponseStatusEnumSerializer();

class _$DeviceRegistrationResponseStatusEnumSerializer
    implements PrimitiveSerializer<DeviceRegistrationResponseStatusEnum> {
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
  final Iterable<Type> types = const <Type>[
    DeviceRegistrationResponseStatusEnum
  ];
  @override
  final String wireName = 'DeviceRegistrationResponseStatusEnum';

  @override
  Object serialize(
          Serializers serializers, DeviceRegistrationResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DeviceRegistrationResponseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DeviceRegistrationResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DeviceRegistrationResponse extends DeviceRegistrationResponse {
  @override
  final DateTime? approvedAt;
  @override
  final String? campId;
  @override
  final DateTime? createdAt;
  @override
  final String? deviceModel;
  @override
  final String? deviceName;
  @override
  final String? displayName;
  @override
  final int? failedPinAttempts;
  @override
  final String? id;
  @override
  final DateTime? lockedUntil;
  @override
  final DeviceRegistrationResponseStatusEnum? status;

  factory _$DeviceRegistrationResponse(
          [void Function(DeviceRegistrationResponseBuilder)? updates]) =>
      (DeviceRegistrationResponseBuilder()..update(updates))._build();

  _$DeviceRegistrationResponse._(
      {this.approvedAt,
      this.campId,
      this.createdAt,
      this.deviceModel,
      this.deviceName,
      this.displayName,
      this.failedPinAttempts,
      this.id,
      this.lockedUntil,
      this.status})
      : super._();
  @override
  DeviceRegistrationResponse rebuild(
          void Function(DeviceRegistrationResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceRegistrationResponseBuilder toBuilder() =>
      DeviceRegistrationResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceRegistrationResponse &&
        approvedAt == other.approvedAt &&
        campId == other.campId &&
        createdAt == other.createdAt &&
        deviceModel == other.deviceModel &&
        deviceName == other.deviceName &&
        displayName == other.displayName &&
        failedPinAttempts == other.failedPinAttempts &&
        id == other.id &&
        lockedUntil == other.lockedUntil &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, approvedAt.hashCode);
    _$hash = $jc(_$hash, campId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, deviceModel.hashCode);
    _$hash = $jc(_$hash, deviceName.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, failedPinAttempts.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, lockedUntil.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceRegistrationResponse')
          ..add('approvedAt', approvedAt)
          ..add('campId', campId)
          ..add('createdAt', createdAt)
          ..add('deviceModel', deviceModel)
          ..add('deviceName', deviceName)
          ..add('displayName', displayName)
          ..add('failedPinAttempts', failedPinAttempts)
          ..add('id', id)
          ..add('lockedUntil', lockedUntil)
          ..add('status', status))
        .toString();
  }
}

class DeviceRegistrationResponseBuilder
    implements
        Builder<DeviceRegistrationResponse, DeviceRegistrationResponseBuilder> {
  _$DeviceRegistrationResponse? _$v;

  DateTime? _approvedAt;
  DateTime? get approvedAt => _$this._approvedAt;
  set approvedAt(DateTime? approvedAt) => _$this._approvedAt = approvedAt;

  String? _campId;
  String? get campId => _$this._campId;
  set campId(String? campId) => _$this._campId = campId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _deviceModel;
  String? get deviceModel => _$this._deviceModel;
  set deviceModel(String? deviceModel) => _$this._deviceModel = deviceModel;

  String? _deviceName;
  String? get deviceName => _$this._deviceName;
  set deviceName(String? deviceName) => _$this._deviceName = deviceName;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  int? _failedPinAttempts;
  int? get failedPinAttempts => _$this._failedPinAttempts;
  set failedPinAttempts(int? failedPinAttempts) =>
      _$this._failedPinAttempts = failedPinAttempts;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _lockedUntil;
  DateTime? get lockedUntil => _$this._lockedUntil;
  set lockedUntil(DateTime? lockedUntil) => _$this._lockedUntil = lockedUntil;

  DeviceRegistrationResponseStatusEnum? _status;
  DeviceRegistrationResponseStatusEnum? get status => _$this._status;
  set status(DeviceRegistrationResponseStatusEnum? status) =>
      _$this._status = status;

  DeviceRegistrationResponseBuilder() {
    DeviceRegistrationResponse._defaults(this);
  }

  DeviceRegistrationResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _approvedAt = $v.approvedAt;
      _campId = $v.campId;
      _createdAt = $v.createdAt;
      _deviceModel = $v.deviceModel;
      _deviceName = $v.deviceName;
      _displayName = $v.displayName;
      _failedPinAttempts = $v.failedPinAttempts;
      _id = $v.id;
      _lockedUntil = $v.lockedUntil;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceRegistrationResponse other) {
    _$v = other as _$DeviceRegistrationResponse;
  }

  @override
  void update(void Function(DeviceRegistrationResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceRegistrationResponse build() => _build();

  _$DeviceRegistrationResponse _build() {
    final _$result = _$v ??
        _$DeviceRegistrationResponse._(
          approvedAt: approvedAt,
          campId: campId,
          createdAt: createdAt,
          deviceModel: deviceModel,
          deviceName: deviceName,
          displayName: displayName,
          failedPinAttempts: failedPinAttempts,
          id: id,
          lockedUntil: lockedUntil,
          status: status,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
