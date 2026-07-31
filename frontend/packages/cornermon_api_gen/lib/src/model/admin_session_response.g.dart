// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_session_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminSessionResponse extends AdminSessionResponse {
  @override
  final String? adminId;
  @override
  final DateTime? createdAt;
  @override
  final String? deviceInfo;
  @override
  final String? id;
  @override
  final DateTime? lastUsedAt;

  factory _$AdminSessionResponse(
          [void Function(AdminSessionResponseBuilder)? updates]) =>
      (AdminSessionResponseBuilder()..update(updates))._build();

  _$AdminSessionResponse._(
      {this.adminId, this.createdAt, this.deviceInfo, this.id, this.lastUsedAt})
      : super._();
  @override
  AdminSessionResponse rebuild(
          void Function(AdminSessionResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminSessionResponseBuilder toBuilder() =>
      AdminSessionResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminSessionResponse &&
        adminId == other.adminId &&
        createdAt == other.createdAt &&
        deviceInfo == other.deviceInfo &&
        id == other.id &&
        lastUsedAt == other.lastUsedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, adminId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, deviceInfo.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, lastUsedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminSessionResponse')
          ..add('adminId', adminId)
          ..add('createdAt', createdAt)
          ..add('deviceInfo', deviceInfo)
          ..add('id', id)
          ..add('lastUsedAt', lastUsedAt))
        .toString();
  }
}

class AdminSessionResponseBuilder
    implements Builder<AdminSessionResponse, AdminSessionResponseBuilder> {
  _$AdminSessionResponse? _$v;

  String? _adminId;
  String? get adminId => _$this._adminId;
  set adminId(String? adminId) => _$this._adminId = adminId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _deviceInfo;
  String? get deviceInfo => _$this._deviceInfo;
  set deviceInfo(String? deviceInfo) => _$this._deviceInfo = deviceInfo;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _lastUsedAt;
  DateTime? get lastUsedAt => _$this._lastUsedAt;
  set lastUsedAt(DateTime? lastUsedAt) => _$this._lastUsedAt = lastUsedAt;

  AdminSessionResponseBuilder() {
    AdminSessionResponse._defaults(this);
  }

  AdminSessionResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _adminId = $v.adminId;
      _createdAt = $v.createdAt;
      _deviceInfo = $v.deviceInfo;
      _id = $v.id;
      _lastUsedAt = $v.lastUsedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminSessionResponse other) {
    _$v = other as _$AdminSessionResponse;
  }

  @override
  void update(void Function(AdminSessionResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminSessionResponse build() => _build();

  _$AdminSessionResponse _build() {
    final _$result = _$v ??
        _$AdminSessionResponse._(
          adminId: adminId,
          createdAt: createdAt,
          deviceInfo: deviceInfo,
          id: id,
          lastUsedAt: lastUsedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
