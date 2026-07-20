// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'track_login_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackLoginRequest extends TrackLoginRequest {
  @override
  final String? pin;

  factory _$TrackLoginRequest(
          [void Function(TrackLoginRequestBuilder)? updates]) =>
      (TrackLoginRequestBuilder()..update(updates))._build();

  _$TrackLoginRequest._({this.pin}) : super._();
  @override
  TrackLoginRequest rebuild(void Function(TrackLoginRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackLoginRequestBuilder toBuilder() =>
      TrackLoginRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackLoginRequest && pin == other.pin;
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
    return (newBuiltValueToStringHelper(r'TrackLoginRequest')..add('pin', pin))
        .toString();
  }
}

class TrackLoginRequestBuilder
    implements Builder<TrackLoginRequest, TrackLoginRequestBuilder> {
  _$TrackLoginRequest? _$v;

  String? _pin;
  String? get pin => _$this._pin;
  set pin(String? pin) => _$this._pin = pin;

  TrackLoginRequestBuilder() {
    TrackLoginRequest._defaults(this);
  }

  TrackLoginRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pin = $v.pin;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackLoginRequest other) {
    _$v = other as _$TrackLoginRequest;
  }

  @override
  void update(void Function(TrackLoginRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackLoginRequest build() => _build();

  _$TrackLoginRequest _build() {
    final _$result = _$v ??
        _$TrackLoginRequest._(
          pin: pin,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
