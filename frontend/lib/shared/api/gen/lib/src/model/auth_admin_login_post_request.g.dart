// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_admin_login_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthAdminLoginPostRequest extends AuthAdminLoginPostRequest {
  @override
  final String id;
  @override
  final String password;

  factory _$AuthAdminLoginPostRequest(
          [void Function(AuthAdminLoginPostRequestBuilder)? updates]) =>
      (AuthAdminLoginPostRequestBuilder()..update(updates))._build();

  _$AuthAdminLoginPostRequest._({required this.id, required this.password})
      : super._();
  @override
  AuthAdminLoginPostRequest rebuild(
          void Function(AuthAdminLoginPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthAdminLoginPostRequestBuilder toBuilder() =>
      AuthAdminLoginPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthAdminLoginPostRequest &&
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
    return (newBuiltValueToStringHelper(r'AuthAdminLoginPostRequest')
          ..add('id', id)
          ..add('password', password))
        .toString();
  }
}

class AuthAdminLoginPostRequestBuilder
    implements
        Builder<AuthAdminLoginPostRequest, AuthAdminLoginPostRequestBuilder> {
  _$AuthAdminLoginPostRequest? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  AuthAdminLoginPostRequestBuilder() {
    AuthAdminLoginPostRequest._defaults(this);
  }

  AuthAdminLoginPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthAdminLoginPostRequest other) {
    _$v = other as _$AuthAdminLoginPostRequest;
  }

  @override
  void update(void Function(AuthAdminLoginPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthAdminLoginPostRequest build() => _build();

  _$AuthAdminLoginPostRequest _build() {
    final _$result = _$v ??
        _$AuthAdminLoginPostRequest._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AuthAdminLoginPostRequest', 'id'),
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'AuthAdminLoginPostRequest', 'password'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
