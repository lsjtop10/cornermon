// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BadgeResponseStatusEnum _$badgeResponseStatusEnum_UNASSIGNED =
    const BadgeResponseStatusEnum._('UNASSIGNED');
const BadgeResponseStatusEnum _$badgeResponseStatusEnum_ASSIGNED =
    const BadgeResponseStatusEnum._('ASSIGNED');

BadgeResponseStatusEnum _$badgeResponseStatusEnumValueOf(String name) {
  switch (name) {
    case 'UNASSIGNED':
      return _$badgeResponseStatusEnum_UNASSIGNED;
    case 'ASSIGNED':
      return _$badgeResponseStatusEnum_ASSIGNED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BadgeResponseStatusEnum> _$badgeResponseStatusEnumValues =
    BuiltSet<BadgeResponseStatusEnum>(const <BadgeResponseStatusEnum>[
  _$badgeResponseStatusEnum_UNASSIGNED,
  _$badgeResponseStatusEnum_ASSIGNED,
]);

Serializer<BadgeResponseStatusEnum> _$badgeResponseStatusEnumSerializer =
    _$BadgeResponseStatusEnumSerializer();

class _$BadgeResponseStatusEnumSerializer
    implements PrimitiveSerializer<BadgeResponseStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'UNASSIGNED': 'UNASSIGNED',
    'ASSIGNED': 'ASSIGNED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'UNASSIGNED': 'UNASSIGNED',
    'ASSIGNED': 'ASSIGNED',
  };

  @override
  final Iterable<Type> types = const <Type>[BadgeResponseStatusEnum];
  @override
  final String wireName = 'BadgeResponseStatusEnum';

  @override
  Object serialize(Serializers serializers, BadgeResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BadgeResponseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BadgeResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BadgeResponse extends BadgeResponse {
  @override
  final String? assignedGroupId;
  @override
  final String? id;
  @override
  final String? qrPayload;
  @override
  final String? shortId;
  @override
  final BadgeResponseStatusEnum? status;

  factory _$BadgeResponse([void Function(BadgeResponseBuilder)? updates]) =>
      (BadgeResponseBuilder()..update(updates))._build();

  _$BadgeResponse._(
      {this.assignedGroupId,
      this.id,
      this.qrPayload,
      this.shortId,
      this.status})
      : super._();
  @override
  BadgeResponse rebuild(void Function(BadgeResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BadgeResponseBuilder toBuilder() => BadgeResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BadgeResponse &&
        assignedGroupId == other.assignedGroupId &&
        id == other.id &&
        qrPayload == other.qrPayload &&
        shortId == other.shortId &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, assignedGroupId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, qrPayload.hashCode);
    _$hash = $jc(_$hash, shortId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BadgeResponse')
          ..add('assignedGroupId', assignedGroupId)
          ..add('id', id)
          ..add('qrPayload', qrPayload)
          ..add('shortId', shortId)
          ..add('status', status))
        .toString();
  }
}

class BadgeResponseBuilder
    implements Builder<BadgeResponse, BadgeResponseBuilder> {
  _$BadgeResponse? _$v;

  String? _assignedGroupId;
  String? get assignedGroupId => _$this._assignedGroupId;
  set assignedGroupId(String? assignedGroupId) =>
      _$this._assignedGroupId = assignedGroupId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _qrPayload;
  String? get qrPayload => _$this._qrPayload;
  set qrPayload(String? qrPayload) => _$this._qrPayload = qrPayload;

  String? _shortId;
  String? get shortId => _$this._shortId;
  set shortId(String? shortId) => _$this._shortId = shortId;

  BadgeResponseStatusEnum? _status;
  BadgeResponseStatusEnum? get status => _$this._status;
  set status(BadgeResponseStatusEnum? status) => _$this._status = status;

  BadgeResponseBuilder() {
    BadgeResponse._defaults(this);
  }

  BadgeResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _assignedGroupId = $v.assignedGroupId;
      _id = $v.id;
      _qrPayload = $v.qrPayload;
      _shortId = $v.shortId;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BadgeResponse other) {
    _$v = other as _$BadgeResponse;
  }

  @override
  void update(void Function(BadgeResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BadgeResponse build() => _build();

  _$BadgeResponse _build() {
    final _$result = _$v ??
        _$BadgeResponse._(
          assignedGroupId: assignedGroupId,
          id: id,
          qrPayload: qrPayload,
          shortId: shortId,
          status: status,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
