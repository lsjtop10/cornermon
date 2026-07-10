// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_session.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminSession extends AdminSession {
  @override
  final String id;
  @override
  final String adminId;
  @override
  final String? deviceInfo;
  @override
  final DateTime createdAt;
  @override
  final DateTime lastUsedAt;

  factory _$AdminSession([void Function(AdminSessionBuilder)? updates]) =>
      (AdminSessionBuilder()..update(updates))._build();

  _$AdminSession._(
      {required this.id,
      required this.adminId,
      this.deviceInfo,
      required this.createdAt,
      required this.lastUsedAt})
      : super._();
  @override
  AdminSession rebuild(void Function(AdminSessionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminSessionBuilder toBuilder() => AdminSessionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminSession &&
        id == other.id &&
        adminId == other.adminId &&
        deviceInfo == other.deviceInfo &&
        createdAt == other.createdAt &&
        lastUsedAt == other.lastUsedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, adminId.hashCode);
    _$hash = $jc(_$hash, deviceInfo.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, lastUsedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminSession')
          ..add('id', id)
          ..add('adminId', adminId)
          ..add('deviceInfo', deviceInfo)
          ..add('createdAt', createdAt)
          ..add('lastUsedAt', lastUsedAt))
        .toString();
  }
}

class AdminSessionBuilder
    implements Builder<AdminSession, AdminSessionBuilder> {
  _$AdminSession? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _adminId;
  String? get adminId => _$this._adminId;
  set adminId(String? adminId) => _$this._adminId = adminId;

  String? _deviceInfo;
  String? get deviceInfo => _$this._deviceInfo;
  set deviceInfo(String? deviceInfo) => _$this._deviceInfo = deviceInfo;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _lastUsedAt;
  DateTime? get lastUsedAt => _$this._lastUsedAt;
  set lastUsedAt(DateTime? lastUsedAt) => _$this._lastUsedAt = lastUsedAt;

  AdminSessionBuilder() {
    AdminSession._defaults(this);
  }

  AdminSessionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _adminId = $v.adminId;
      _deviceInfo = $v.deviceInfo;
      _createdAt = $v.createdAt;
      _lastUsedAt = $v.lastUsedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminSession other) {
    _$v = other as _$AdminSession;
  }

  @override
  void update(void Function(AdminSessionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminSession build() => _build();

  _$AdminSession _build() {
    final _$result = _$v ??
        _$AdminSession._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'AdminSession', 'id'),
          adminId: BuiltValueNullFieldError.checkNotNull(
              adminId, r'AdminSession', 'adminId'),
          deviceInfo: deviceInfo,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'AdminSession', 'createdAt'),
          lastUsedAt: BuiltValueNullFieldError.checkNotNull(
              lastUsedAt, r'AdminSession', 'lastUsedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
