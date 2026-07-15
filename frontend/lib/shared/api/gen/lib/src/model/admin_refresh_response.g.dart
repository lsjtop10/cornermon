// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_refresh_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminRefreshResponse extends AdminRefreshResponse {
  @override
  final String? accessToken;
  @override
  final int? expiresInSeconds;

  factory _$AdminRefreshResponse(
          [void Function(AdminRefreshResponseBuilder)? updates]) =>
      (AdminRefreshResponseBuilder()..update(updates))._build();

  _$AdminRefreshResponse._({this.accessToken, this.expiresInSeconds})
      : super._();
  @override
  AdminRefreshResponse rebuild(
          void Function(AdminRefreshResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminRefreshResponseBuilder toBuilder() =>
      AdminRefreshResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminRefreshResponse &&
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
    return (newBuiltValueToStringHelper(r'AdminRefreshResponse')
          ..add('accessToken', accessToken)
          ..add('expiresInSeconds', expiresInSeconds))
        .toString();
  }
}

class AdminRefreshResponseBuilder
    implements Builder<AdminRefreshResponse, AdminRefreshResponseBuilder> {
  _$AdminRefreshResponse? _$v;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  int? _expiresInSeconds;
  int? get expiresInSeconds => _$this._expiresInSeconds;
  set expiresInSeconds(int? expiresInSeconds) =>
      _$this._expiresInSeconds = expiresInSeconds;

  AdminRefreshResponseBuilder() {
    AdminRefreshResponse._defaults(this);
  }

  AdminRefreshResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _expiresInSeconds = $v.expiresInSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminRefreshResponse other) {
    _$v = other as _$AdminRefreshResponse;
  }

  @override
  void update(void Function(AdminRefreshResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminRefreshResponse build() => _build();

  _$AdminRefreshResponse _build() {
    final _$result = _$v ??
        _$AdminRefreshResponse._(
          accessToken: accessToken,
          expiresInSeconds: expiresInSeconds,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
