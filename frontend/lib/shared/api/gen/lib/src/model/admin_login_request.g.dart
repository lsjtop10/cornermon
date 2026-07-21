// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_login_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminLoginRequest extends AdminLoginRequest {
  @override
  final String? id;
  @override
  final String? password;

  factory _$AdminLoginRequest(
          [void Function(AdminLoginRequestBuilder)? updates]) =>
      (AdminLoginRequestBuilder()..update(updates))._build();

  _$AdminLoginRequest._({this.id, this.password}) : super._();
  @override
  AdminLoginRequest rebuild(void Function(AdminLoginRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminLoginRequestBuilder toBuilder() =>
      AdminLoginRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminLoginRequest &&
        id == other.id &&
        password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminLoginRequest')
          ..add('id', id)
          ..add('password', password))
        .toString();
  }
}

class AdminLoginRequestBuilder
    implements Builder<AdminLoginRequest, AdminLoginRequestBuilder> {
  _$AdminLoginRequest? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  AdminLoginRequestBuilder() {
    AdminLoginRequest._defaults(this);
  }

  AdminLoginRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminLoginRequest other) {
    _$v = other as _$AdminLoginRequest;
  }

  @override
  void update(void Function(AdminLoginRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminLoginRequest build() => _build();

  _$AdminLoginRequest _build() {
    final _$result = _$v ??
        _$AdminLoginRequest._(
          id: id,
          password: password,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
