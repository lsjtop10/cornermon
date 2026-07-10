// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_track_login_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthTrackLoginPost200Response extends AuthTrackLoginPost200Response {
  @override
  final String? trackToken;
  @override
  final Track? track;
  @override
  final AuthTrackLoginPost200ResponseCorner? corner;

  factory _$AuthTrackLoginPost200Response(
          [void Function(AuthTrackLoginPost200ResponseBuilder)? updates]) =>
      (AuthTrackLoginPost200ResponseBuilder()..update(updates))._build();

  _$AuthTrackLoginPost200Response._({this.trackToken, this.track, this.corner})
      : super._();
  @override
  AuthTrackLoginPost200Response rebuild(
          void Function(AuthTrackLoginPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthTrackLoginPost200ResponseBuilder toBuilder() =>
      AuthTrackLoginPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthTrackLoginPost200Response &&
        trackToken == other.trackToken &&
        track == other.track &&
        corner == other.corner;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, trackToken.hashCode);
    _$hash = $jc(_$hash, track.hashCode);
    _$hash = $jc(_$hash, corner.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthTrackLoginPost200Response')
          ..add('trackToken', trackToken)
          ..add('track', track)
          ..add('corner', corner))
        .toString();
  }
}

class AuthTrackLoginPost200ResponseBuilder
    implements
        Builder<AuthTrackLoginPost200Response,
            AuthTrackLoginPost200ResponseBuilder> {
  _$AuthTrackLoginPost200Response? _$v;

  String? _trackToken;
  String? get trackToken => _$this._trackToken;
  set trackToken(String? trackToken) => _$this._trackToken = trackToken;

  TrackBuilder? _track;
  TrackBuilder get track => _$this._track ??= TrackBuilder();
  set track(TrackBuilder? track) => _$this._track = track;

  AuthTrackLoginPost200ResponseCornerBuilder? _corner;
  AuthTrackLoginPost200ResponseCornerBuilder get corner =>
      _$this._corner ??= AuthTrackLoginPost200ResponseCornerBuilder();
  set corner(AuthTrackLoginPost200ResponseCornerBuilder? corner) =>
      _$this._corner = corner;

  AuthTrackLoginPost200ResponseBuilder() {
    AuthTrackLoginPost200Response._defaults(this);
  }

  AuthTrackLoginPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _trackToken = $v.trackToken;
      _track = $v.track?.toBuilder();
      _corner = $v.corner?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthTrackLoginPost200Response other) {
    _$v = other as _$AuthTrackLoginPost200Response;
  }

  @override
  void update(void Function(AuthTrackLoginPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthTrackLoginPost200Response build() => _build();

  _$AuthTrackLoginPost200Response _build() {
    _$AuthTrackLoginPost200Response _$result;
    try {
      _$result = _$v ??
          _$AuthTrackLoginPost200Response._(
            trackToken: trackToken,
            track: _track?.build(),
            corner: _corner?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'track';
        _track?.build();
        _$failedField = 'corner';
        _corner?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AuthTrackLoginPost200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
