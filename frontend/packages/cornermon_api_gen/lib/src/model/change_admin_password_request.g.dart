// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_admin_password_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChangeAdminPasswordRequest extends ChangeAdminPasswordRequest {
  @override
  final String? password;

  factory _$ChangeAdminPasswordRequest(
          [void Function(ChangeAdminPasswordRequestBuilder)? updates]) =>
      (ChangeAdminPasswordRequestBuilder()..update(updates))._build();

  _$ChangeAdminPasswordRequest._({this.password}) : super._();
  @override
  ChangeAdminPasswordRequest rebuild(
          void Function(ChangeAdminPasswordRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChangeAdminPasswordRequestBuilder toBuilder() =>
      ChangeAdminPasswordRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChangeAdminPasswordRequest && password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChangeAdminPasswordRequest')
          ..add('password', password))
        .toString();
  }
}

class ChangeAdminPasswordRequestBuilder
    implements
        Builder<ChangeAdminPasswordRequest, ChangeAdminPasswordRequestBuilder> {
  _$ChangeAdminPasswordRequest? _$v;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  ChangeAdminPasswordRequestBuilder() {
    ChangeAdminPasswordRequest._defaults(this);
  }

  ChangeAdminPasswordRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChangeAdminPasswordRequest other) {
    _$v = other as _$ChangeAdminPasswordRequest;
  }

  @override
  void update(void Function(ChangeAdminPasswordRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChangeAdminPasswordRequest build() => _build();

  _$ChangeAdminPasswordRequest _build() {
    final _$result = _$v ??
        _$ChangeAdminPasswordRequest._(
          password: password,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
