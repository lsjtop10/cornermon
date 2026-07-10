// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_admin_login_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthAdminLoginPost200Response extends AuthAdminLoginPost200Response {
  @override
  final String? accessToken;
  @override
  final String? refreshToken;
  @override
  final int? expiresInSeconds;

  factory _$AuthAdminLoginPost200Response(
          [void Function(AuthAdminLoginPost200ResponseBuilder)? updates]) =>
      (AuthAdminLoginPost200ResponseBuilder()..update(updates))._build();

  _$AuthAdminLoginPost200Response._(
      {this.accessToken, this.refreshToken, this.expiresInSeconds})
      : super._();
  @override
  AuthAdminLoginPost200Response rebuild(
          void Function(AuthAdminLoginPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthAdminLoginPost200ResponseBuilder toBuilder() =>
      AuthAdminLoginPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthAdminLoginPost200Response &&
        accessToken == other.accessToken &&
        refreshToken == other.refreshToken &&
        expiresInSeconds == other.expiresInSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jc(_$hash, expiresInSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthAdminLoginPost200Response')
          ..add('accessToken', accessToken)
          ..add('refreshToken', refreshToken)
          ..add('expiresInSeconds', expiresInSeconds))
        .toString();
  }
}

class AuthAdminLoginPost200ResponseBuilder
    implements
        Builder<AuthAdminLoginPost200Response,
            AuthAdminLoginPost200ResponseBuilder> {
  _$AuthAdminLoginPost200Response? _$v;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  int? _expiresInSeconds;
  int? get expiresInSeconds => _$this._expiresInSeconds;
  set expiresInSeconds(int? expiresInSeconds) =>
      _$this._expiresInSeconds = expiresInSeconds;

  AuthAdminLoginPost200ResponseBuilder() {
    AuthAdminLoginPost200Response._defaults(this);
  }

  AuthAdminLoginPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _refreshToken = $v.refreshToken;
      _expiresInSeconds = $v.expiresInSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthAdminLoginPost200Response other) {
    _$v = other as _$AuthAdminLoginPost200Response;
  }

  @override
  void update(void Function(AuthAdminLoginPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthAdminLoginPost200Response build() => _build();

  _$AuthAdminLoginPost200Response _build() {
    final _$result = _$v ??
        _$AuthAdminLoginPost200Response._(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresInSeconds: expiresInSeconds,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
