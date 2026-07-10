// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Badge extends Badge {
  @override
  final String id;
  @override
  final String shortId;
  @override
  final String? qrPayload;
  @override
  final BadgeStatus status;
  @override
  final String? assignedGroupId;

  factory _$Badge([void Function(BadgeBuilder)? updates]) =>
      (BadgeBuilder()..update(updates))._build();

  _$Badge._({
    required this.id,
    required this.shortId,
    this.qrPayload,
    required this.status,
    this.assignedGroupId,
  }) : super._();
  @override
  Badge rebuild(void Function(BadgeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BadgeBuilder toBuilder() => BadgeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Badge &&
        id == other.id &&
        shortId == other.shortId &&
        qrPayload == other.qrPayload &&
        status == other.status &&
        assignedGroupId == other.assignedGroupId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, shortId.hashCode);
    _$hash = $jc(_$hash, qrPayload.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, assignedGroupId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Badge')
          ..add('id', id)
          ..add('shortId', shortId)
          ..add('qrPayload', qrPayload)
          ..add('status', status)
          ..add('assignedGroupId', assignedGroupId))
        .toString();
  }
}

class BadgeBuilder implements Builder<Badge, BadgeBuilder> {
  _$Badge? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _shortId;
  String? get shortId => _$this._shortId;
  set shortId(String? shortId) => _$this._shortId = shortId;

  String? _qrPayload;
  String? get qrPayload => _$this._qrPayload;
  set qrPayload(String? qrPayload) => _$this._qrPayload = qrPayload;

  BadgeStatus? _status;
  BadgeStatus? get status => _$this._status;
  set status(BadgeStatus? status) => _$this._status = status;

  String? _assignedGroupId;
  String? get assignedGroupId => _$this._assignedGroupId;
  set assignedGroupId(String? assignedGroupId) =>
      _$this._assignedGroupId = assignedGroupId;

  BadgeBuilder() {
    Badge._defaults(this);
  }

  BadgeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _shortId = $v.shortId;
      _qrPayload = $v.qrPayload;
      _status = $v.status;
      _assignedGroupId = $v.assignedGroupId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Badge other) {
    _$v = other as _$Badge;
  }

  @override
  void update(void Function(BadgeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Badge build() => _build();

  _$Badge _build() {
    final _$result =
        _$v ??
        _$Badge._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Badge', 'id'),
          shortId: BuiltValueNullFieldError.checkNotNull(
            shortId,
            r'Badge',
            'shortId',
          ),
          qrPayload: qrPayload,
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'Badge',
            'status',
          ),
          assignedGroupId: assignedGroupId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
