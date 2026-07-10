// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_track_login_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthTrackLoginPostRequest extends AuthTrackLoginPostRequest {
  @override
  final String pin;

  factory _$AuthTrackLoginPostRequest(
          [void Function(AuthTrackLoginPostRequestBuilder)? updates]) =>
      (AuthTrackLoginPostRequestBuilder()..update(updates))._build();

  _$AuthTrackLoginPostRequest._({required this.pin}) : super._();
  @override
  AuthTrackLoginPostRequest rebuild(
          void Function(AuthTrackLoginPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthTrackLoginPostRequestBuilder toBuilder() =>
      AuthTrackLoginPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthTrackLoginPostRequest && pin == other.pin;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pin.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthTrackLoginPostRequest')
          ..add('pin', pin))
        .toString();
  }
}

class AuthTrackLoginPostRequestBuilder
    implements
        Builder<AuthTrackLoginPostRequest, AuthTrackLoginPostRequestBuilder> {
  _$AuthTrackLoginPostRequest? _$v;

  String? _pin;
  String? get pin => _$this._pin;
  set pin(String? pin) => _$this._pin = pin;

  AuthTrackLoginPostRequestBuilder() {
    AuthTrackLoginPostRequest._defaults(this);
  }

  AuthTrackLoginPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pin = $v.pin;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthTrackLoginPostRequest other) {
    _$v = other as _$AuthTrackLoginPostRequest;
  }

  @override
  void update(void Function(AuthTrackLoginPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthTrackLoginPostRequest build() => _build();

  _$AuthTrackLoginPostRequest _build() {
    final _$result = _$v ??
        _$AuthTrackLoginPostRequest._(
          pin: BuiltValueNullFieldError.checkNotNull(
              pin, r'AuthTrackLoginPostRequest', 'pin'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
