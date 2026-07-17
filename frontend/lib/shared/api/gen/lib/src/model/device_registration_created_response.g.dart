// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_registration_created_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DeviceRegistrationCreatedResponseStatusEnum
    _$deviceRegistrationCreatedResponseStatusEnum_PENDING =
    const DeviceRegistrationCreatedResponseStatusEnum._('PENDING');
const DeviceRegistrationCreatedResponseStatusEnum
    _$deviceRegistrationCreatedResponseStatusEnum_APPROVED =
    const DeviceRegistrationCreatedResponseStatusEnum._('APPROVED');
const DeviceRegistrationCreatedResponseStatusEnum
    _$deviceRegistrationCreatedResponseStatusEnum_REJECTED =
    const DeviceRegistrationCreatedResponseStatusEnum._('REJECTED');
const DeviceRegistrationCreatedResponseStatusEnum
    _$deviceRegistrationCreatedResponseStatusEnum_REVOKED =
    const DeviceRegistrationCreatedResponseStatusEnum._('REVOKED');

DeviceRegistrationCreatedResponseStatusEnum
    _$deviceRegistrationCreatedResponseStatusEnumValueOf(String name) {
  switch (name) {
    case 'PENDING':
      return _$deviceRegistrationCreatedResponseStatusEnum_PENDING;
    case 'APPROVED':
      return _$deviceRegistrationCreatedResponseStatusEnum_APPROVED;
    case 'REJECTED':
      return _$deviceRegistrationCreatedResponseStatusEnum_REJECTED;
    case 'REVOKED':
      return _$deviceRegistrationCreatedResponseStatusEnum_REVOKED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DeviceRegistrationCreatedResponseStatusEnum>
    _$deviceRegistrationCreatedResponseStatusEnumValues = BuiltSet<
        DeviceRegistrationCreatedResponseStatusEnum>(const <DeviceRegistrationCreatedResponseStatusEnum>[
  _$deviceRegistrationCreatedResponseStatusEnum_PENDING,
  _$deviceRegistrationCreatedResponseStatusEnum_APPROVED,
  _$deviceRegistrationCreatedResponseStatusEnum_REJECTED,
  _$deviceRegistrationCreatedResponseStatusEnum_REVOKED,
]);

Serializer<DeviceRegistrationCreatedResponseStatusEnum>
    _$deviceRegistrationCreatedResponseStatusEnumSerializer =
    _$DeviceRegistrationCreatedResponseStatusEnumSerializer();

class _$DeviceRegistrationCreatedResponseStatusEnumSerializer
    implements
        PrimitiveSerializer<DeviceRegistrationCreatedResponseStatusEnum> {
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
    DeviceRegistrationCreatedResponseStatusEnum
  ];
  @override
  final String wireName = 'DeviceRegistrationCreatedResponseStatusEnum';

  @override
  Object serialize(Serializers serializers,
          DeviceRegistrationCreatedResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DeviceRegistrationCreatedResponseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DeviceRegistrationCreatedResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DeviceRegistrationCreatedResponse
    extends DeviceRegistrationCreatedResponse {
  @override
  final DateTime? approvedAt;
  @override
  final DateTime? createdAt;
  @override
  final String? deviceModel;
  @override
  final String? deviceName;
  @override
  final String? deviceToken;
  @override
  final String? displayName;
  @override
  final int? failedPinAttempts;
  @override
  final String? id;
  @override
  final DateTime? lockedUntil;
  @override
  final DeviceRegistrationCreatedResponseStatusEnum? status;

  factory _$DeviceRegistrationCreatedResponse(
          [void Function(DeviceRegistrationCreatedResponseBuilder)? updates]) =>
      (DeviceRegistrationCreatedResponseBuilder()..update(updates))._build();

  _$DeviceRegistrationCreatedResponse._(
      {this.approvedAt,
      this.createdAt,
      this.deviceModel,
      this.deviceName,
      this.deviceToken,
      this.displayName,
      this.failedPinAttempts,
      this.id,
      this.lockedUntil,
      this.status})
      : super._();
  @override
  DeviceRegistrationCreatedResponse rebuild(
          void Function(DeviceRegistrationCreatedResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceRegistrationCreatedResponseBuilder toBuilder() =>
      DeviceRegistrationCreatedResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceRegistrationCreatedResponse &&
        approvedAt == other.approvedAt &&
        createdAt == other.createdAt &&
        deviceModel == other.deviceModel &&
        deviceName == other.deviceName &&
        deviceToken == other.deviceToken &&
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
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, deviceModel.hashCode);
    _$hash = $jc(_$hash, deviceName.hashCode);
    _$hash = $jc(_$hash, deviceToken.hashCode);
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
    return (newBuiltValueToStringHelper(r'DeviceRegistrationCreatedResponse')
          ..add('approvedAt', approvedAt)
          ..add('createdAt', createdAt)
          ..add('deviceModel', deviceModel)
          ..add('deviceName', deviceName)
          ..add('deviceToken', deviceToken)
          ..add('displayName', displayName)
          ..add('failedPinAttempts', failedPinAttempts)
          ..add('id', id)
          ..add('lockedUntil', lockedUntil)
          ..add('status', status))
        .toString();
  }
}

class DeviceRegistrationCreatedResponseBuilder
    implements
        Builder<DeviceRegistrationCreatedResponse,
            DeviceRegistrationCreatedResponseBuilder> {
  _$DeviceRegistrationCreatedResponse? _$v;

  DateTime? _approvedAt;
  DateTime? get approvedAt => _$this._approvedAt;
  set approvedAt(DateTime? approvedAt) => _$this._approvedAt = approvedAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _deviceModel;
  String? get deviceModel => _$this._deviceModel;
  set deviceModel(String? deviceModel) => _$this._deviceModel = deviceModel;

  String? _deviceName;
  String? get deviceName => _$this._deviceName;
  set deviceName(String? deviceName) => _$this._deviceName = deviceName;

  String? _deviceToken;
  String? get deviceToken => _$this._deviceToken;
  set deviceToken(String? deviceToken) => _$this._deviceToken = deviceToken;

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

  DeviceRegistrationCreatedResponseStatusEnum? _status;
  DeviceRegistrationCreatedResponseStatusEnum? get status => _$this._status;
  set status(DeviceRegistrationCreatedResponseStatusEnum? status) =>
      _$this._status = status;

  DeviceRegistrationCreatedResponseBuilder() {
    DeviceRegistrationCreatedResponse._defaults(this);
  }

  DeviceRegistrationCreatedResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _approvedAt = $v.approvedAt;
      _createdAt = $v.createdAt;
      _deviceModel = $v.deviceModel;
      _deviceName = $v.deviceName;
      _deviceToken = $v.deviceToken;
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
  void replace(DeviceRegistrationCreatedResponse other) {
    _$v = other as _$DeviceRegistrationCreatedResponse;
  }

  @override
  void update(
      void Function(DeviceRegistrationCreatedResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceRegistrationCreatedResponse build() => _build();

  _$DeviceRegistrationCreatedResponse _build() {
    final _$result = _$v ??
        _$DeviceRegistrationCreatedResponse._(
          approvedAt: approvedAt,
          createdAt: createdAt,
          deviceModel: deviceModel,
          deviceName: deviceName,
          deviceToken: deviceToken,
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
