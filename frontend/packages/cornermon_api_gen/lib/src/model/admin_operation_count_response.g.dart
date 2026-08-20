// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_operation_count_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminOperationCountResponse extends AdminOperationCountResponse {
  @override
  final String? adminId;
  @override
  final String? adminName;
  @override
  final int? count;

  factory _$AdminOperationCountResponse(
          [void Function(AdminOperationCountResponseBuilder)? updates]) =>
      (AdminOperationCountResponseBuilder()..update(updates))._build();

  _$AdminOperationCountResponse._({this.adminId, this.adminName, this.count})
      : super._();
  @override
  AdminOperationCountResponse rebuild(
          void Function(AdminOperationCountResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminOperationCountResponseBuilder toBuilder() =>
      AdminOperationCountResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminOperationCountResponse &&
        adminId == other.adminId &&
        adminName == other.adminName &&
        count == other.count;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, adminId.hashCode);
    _$hash = $jc(_$hash, adminName.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminOperationCountResponse')
          ..add('adminId', adminId)
          ..add('adminName', adminName)
          ..add('count', count))
        .toString();
  }
}

class AdminOperationCountResponseBuilder
    implements
        Builder<AdminOperationCountResponse,
            AdminOperationCountResponseBuilder> {
  _$AdminOperationCountResponse? _$v;

  String? _adminId;
  String? get adminId => _$this._adminId;
  set adminId(String? adminId) => _$this._adminId = adminId;

  String? _adminName;
  String? get adminName => _$this._adminName;
  set adminName(String? adminName) => _$this._adminName = adminName;

  int? _count;
  int? get count => _$this._count;
  set count(int? count) => _$this._count = count;

  AdminOperationCountResponseBuilder() {
    AdminOperationCountResponse._defaults(this);
  }

  AdminOperationCountResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _adminId = $v.adminId;
      _adminName = $v.adminName;
      _count = $v.count;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminOperationCountResponse other) {
    _$v = other as _$AdminOperationCountResponse;
  }

  @override
  void update(void Function(AdminOperationCountResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminOperationCountResponse build() => _build();

  _$AdminOperationCountResponse _build() {
    final _$result = _$v ??
        _$AdminOperationCountResponse._(
          adminId: adminId,
          adminName: adminName,
          count: count,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
