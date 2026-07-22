// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'admin_login_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminLoginResponse extends AdminLoginResponse {
  @override
  final String? accessToken;
  @override
  final int? expiresInSeconds;

  factory _$AdminLoginResponse(
          [void Function(AdminLoginResponseBuilder)? updates]) =>
      (AdminLoginResponseBuilder()..update(updates))._build();

  _$AdminLoginResponse._({this.accessToken, this.expiresInSeconds}) : super._();
  @override
  AdminLoginResponse rebuild(
          void Function(AdminLoginResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminLoginResponseBuilder toBuilder() =>
      AdminLoginResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminLoginResponse &&
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
    return (newBuiltValueToStringHelper(r'AdminLoginResponse')
          ..add('accessToken', accessToken)
          ..add('expiresInSeconds', expiresInSeconds))
        .toString();
  }
}

class AdminLoginResponseBuilder
    implements Builder<AdminLoginResponse, AdminLoginResponseBuilder> {
  _$AdminLoginResponse? _$v;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  int? _expiresInSeconds;
  int? get expiresInSeconds => _$this._expiresInSeconds;
  set expiresInSeconds(int? expiresInSeconds) =>
      _$this._expiresInSeconds = expiresInSeconds;

  AdminLoginResponseBuilder() {
    AdminLoginResponse._defaults(this);
  }

  AdminLoginResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _expiresInSeconds = $v.expiresInSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminLoginResponse other) {
    _$v = other as _$AdminLoginResponse;
  }

  @override
  void update(void Function(AdminLoginResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminLoginResponse build() => _build();

  _$AdminLoginResponse _build() {
    final _$result = _$v ??
        _$AdminLoginResponse._(
          accessToken: accessToken,
          expiresInSeconds: expiresInSeconds,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
