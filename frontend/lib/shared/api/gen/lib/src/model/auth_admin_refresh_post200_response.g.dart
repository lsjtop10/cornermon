// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_admin_refresh_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthAdminRefreshPost200Response
    extends AuthAdminRefreshPost200Response {
  @override
  final String? accessToken;
  @override
  final int? expiresInSeconds;

  factory _$AuthAdminRefreshPost200Response([
    void Function(AuthAdminRefreshPost200ResponseBuilder)? updates,
  ]) => (AuthAdminRefreshPost200ResponseBuilder()..update(updates))._build();

  _$AuthAdminRefreshPost200Response._({this.accessToken, this.expiresInSeconds})
    : super._();
  @override
  AuthAdminRefreshPost200Response rebuild(
    void Function(AuthAdminRefreshPost200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthAdminRefreshPost200ResponseBuilder toBuilder() =>
      AuthAdminRefreshPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthAdminRefreshPost200Response &&
        accessToken == other.accessToken &&
        expiresInSeconds == other.expiresInSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, expiresInSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthAdminRefreshPost200Response')
          ..add('accessToken', accessToken)
          ..add('expiresInSeconds', expiresInSeconds))
        .toString();
  }
}

class AuthAdminRefreshPost200ResponseBuilder
    implements
        Builder<
          AuthAdminRefreshPost200Response,
          AuthAdminRefreshPost200ResponseBuilder
        > {
  _$AuthAdminRefreshPost200Response? _$v;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  int? _expiresInSeconds;
  int? get expiresInSeconds => _$this._expiresInSeconds;
  set expiresInSeconds(int? expiresInSeconds) =>
      _$this._expiresInSeconds = expiresInSeconds;

  AuthAdminRefreshPost200ResponseBuilder() {
    AuthAdminRefreshPost200Response._defaults(this);
  }

  AuthAdminRefreshPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _expiresInSeconds = $v.expiresInSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthAdminRefreshPost200Response other) {
    _$v = other as _$AuthAdminRefreshPost200Response;
  }

  @override
  void update(void Function(AuthAdminRefreshPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthAdminRefreshPost200Response build() => _build();

  _$AuthAdminRefreshPost200Response _build() {
    final _$result =
        _$v ??
        _$AuthAdminRefreshPost200Response._(
          accessToken: accessToken,
          expiresInSeconds: expiresInSeconds,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
