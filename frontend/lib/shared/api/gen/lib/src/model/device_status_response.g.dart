// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_status_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DeviceStatusResponseCampStatusEnum
    _$deviceStatusResponseCampStatusEnum_PENDING =
    const DeviceStatusResponseCampStatusEnum._('PENDING');
const DeviceStatusResponseCampStatusEnum
    _$deviceStatusResponseCampStatusEnum_ACTIVE =
    const DeviceStatusResponseCampStatusEnum._('ACTIVE');
const DeviceStatusResponseCampStatusEnum
    _$deviceStatusResponseCampStatusEnum_ENDED =
    const DeviceStatusResponseCampStatusEnum._('ENDED');

DeviceStatusResponseCampStatusEnum _$deviceStatusResponseCampStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'PENDING':
      return _$deviceStatusResponseCampStatusEnum_PENDING;
    case 'ACTIVE':
      return _$deviceStatusResponseCampStatusEnum_ACTIVE;
    case 'ENDED':
      return _$deviceStatusResponseCampStatusEnum_ENDED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DeviceStatusResponseCampStatusEnum>
    _$deviceStatusResponseCampStatusEnumValues = BuiltSet<
        DeviceStatusResponseCampStatusEnum>(const <DeviceStatusResponseCampStatusEnum>[
  _$deviceStatusResponseCampStatusEnum_PENDING,
  _$deviceStatusResponseCampStatusEnum_ACTIVE,
  _$deviceStatusResponseCampStatusEnum_ENDED,
]);

const DeviceStatusResponseStatusEnum _$deviceStatusResponseStatusEnum_PENDING =
    const DeviceStatusResponseStatusEnum._('PENDING');
const DeviceStatusResponseStatusEnum _$deviceStatusResponseStatusEnum_APPROVED =
    const DeviceStatusResponseStatusEnum._('APPROVED');
const DeviceStatusResponseStatusEnum _$deviceStatusResponseStatusEnum_REJECTED =
    const DeviceStatusResponseStatusEnum._('REJECTED');
const DeviceStatusResponseStatusEnum _$deviceStatusResponseStatusEnum_REVOKED =
    const DeviceStatusResponseStatusEnum._('REVOKED');

DeviceStatusResponseStatusEnum _$deviceStatusResponseStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'PENDING':
      return _$deviceStatusResponseStatusEnum_PENDING;
    case 'APPROVED':
      return _$deviceStatusResponseStatusEnum_APPROVED;
    case 'REJECTED':
      return _$deviceStatusResponseStatusEnum_REJECTED;
    case 'REVOKED':
      return _$deviceStatusResponseStatusEnum_REVOKED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DeviceStatusResponseStatusEnum>
    _$deviceStatusResponseStatusEnumValues = BuiltSet<
        DeviceStatusResponseStatusEnum>(const <DeviceStatusResponseStatusEnum>[
  _$deviceStatusResponseStatusEnum_PENDING,
  _$deviceStatusResponseStatusEnum_APPROVED,
  _$deviceStatusResponseStatusEnum_REJECTED,
  _$deviceStatusResponseStatusEnum_REVOKED,
]);

Serializer<DeviceStatusResponseCampStatusEnum>
    _$deviceStatusResponseCampStatusEnumSerializer =
    _$DeviceStatusResponseCampStatusEnumSerializer();
Serializer<DeviceStatusResponseStatusEnum>
    _$deviceStatusResponseStatusEnumSerializer =
    _$DeviceStatusResponseStatusEnumSerializer();

class _$DeviceStatusResponseCampStatusEnumSerializer
    implements PrimitiveSerializer<DeviceStatusResponseCampStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PENDING': 'PENDING',
    'ACTIVE': 'ACTIVE',
    'ENDED': 'ENDED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PENDING': 'PENDING',
    'ACTIVE': 'ACTIVE',
    'ENDED': 'ENDED',
  };

  @override
  final Iterable<Type> types = const <Type>[DeviceStatusResponseCampStatusEnum];
  @override
  final String wireName = 'DeviceStatusResponseCampStatusEnum';

  @override
  Object serialize(
          Serializers serializers, DeviceStatusResponseCampStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DeviceStatusResponseCampStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DeviceStatusResponseCampStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DeviceStatusResponseStatusEnumSerializer
    implements PrimitiveSerializer<DeviceStatusResponseStatusEnum> {
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
  final Iterable<Type> types = const <Type>[DeviceStatusResponseStatusEnum];
  @override
  final String wireName = 'DeviceStatusResponseStatusEnum';

  @override
  Object serialize(
          Serializers serializers, DeviceStatusResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DeviceStatusResponseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DeviceStatusResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DeviceStatusResponse extends DeviceStatusResponse {
  @override
  final String? campId;
  @override
  final DeviceStatusResponseCampStatusEnum? campStatus;
  @override
  final String? id;
  @override
  final DeviceStatusResponseStatusEnum? status;

  factory _$DeviceStatusResponse(
          [void Function(DeviceStatusResponseBuilder)? updates]) =>
      (DeviceStatusResponseBuilder()..update(updates))._build();

  _$DeviceStatusResponse._({this.campId, this.campStatus, this.id, this.status})
      : super._();
  @override
  DeviceStatusResponse rebuild(
          void Function(DeviceStatusResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceStatusResponseBuilder toBuilder() =>
      DeviceStatusResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceStatusResponse &&
        campId == other.campId &&
        campStatus == other.campStatus &&
        id == other.id &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, campId.hashCode);
    _$hash = $jc(_$hash, campStatus.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceStatusResponse')
          ..add('campId', campId)
          ..add('campStatus', campStatus)
          ..add('id', id)
          ..add('status', status))
        .toString();
  }
}

class DeviceStatusResponseBuilder
    implements Builder<DeviceStatusResponse, DeviceStatusResponseBuilder> {
  _$DeviceStatusResponse? _$v;

  String? _campId;
  String? get campId => _$this._campId;
  set campId(String? campId) => _$this._campId = campId;

  DeviceStatusResponseCampStatusEnum? _campStatus;
  DeviceStatusResponseCampStatusEnum? get campStatus => _$this._campStatus;
  set campStatus(DeviceStatusResponseCampStatusEnum? campStatus) =>
      _$this._campStatus = campStatus;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DeviceStatusResponseStatusEnum? _status;
  DeviceStatusResponseStatusEnum? get status => _$this._status;
  set status(DeviceStatusResponseStatusEnum? status) => _$this._status = status;

  DeviceStatusResponseBuilder() {
    DeviceStatusResponse._defaults(this);
  }

  DeviceStatusResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _campId = $v.campId;
      _campStatus = $v.campStatus;
      _id = $v.id;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceStatusResponse other) {
    _$v = other as _$DeviceStatusResponse;
  }

  @override
  void update(void Function(DeviceStatusResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceStatusResponse build() => _build();

  _$DeviceStatusResponse _build() {
    final _$result = _$v ??
        _$DeviceStatusResponse._(
          campId: campId,
          campStatus: campStatus,
          id: id,
          status: status,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
