// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'track_login_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackLoginResponse extends TrackLoginResponse {
  @override
  final CornerResponse? corner;
  @override
  final TrackResponse? track;
  @override
  final String? trackToken;

  factory _$TrackLoginResponse(
          [void Function(TrackLoginResponseBuilder)? updates]) =>
      (TrackLoginResponseBuilder()..update(updates))._build();

  _$TrackLoginResponse._({this.corner, this.track, this.trackToken})
      : super._();
  @override
  TrackLoginResponse rebuild(
          void Function(TrackLoginResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackLoginResponseBuilder toBuilder() =>
      TrackLoginResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackLoginResponse &&
        corner == other.corner &&
        track == other.track &&
        trackToken == other.trackToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, corner.hashCode);
    _$hash = $jc(_$hash, track.hashCode);
    _$hash = $jc(_$hash, trackToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackLoginResponse')
          ..add('corner', corner)
          ..add('track', track)
          ..add('trackToken', trackToken))
        .toString();
  }
}

class TrackLoginResponseBuilder
    implements Builder<TrackLoginResponse, TrackLoginResponseBuilder> {
  _$TrackLoginResponse? _$v;

  CornerResponseBuilder? _corner;
  CornerResponseBuilder get corner =>
      _$this._corner ??= CornerResponseBuilder();
  set corner(CornerResponseBuilder? corner) => _$this._corner = corner;

  TrackResponseBuilder? _track;
  TrackResponseBuilder get track => _$this._track ??= TrackResponseBuilder();
  set track(TrackResponseBuilder? track) => _$this._track = track;

  String? _trackToken;
  String? get trackToken => _$this._trackToken;
  set trackToken(String? trackToken) => _$this._trackToken = trackToken;

  TrackLoginResponseBuilder() {
    TrackLoginResponse._defaults(this);
  }

  TrackLoginResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _corner = $v.corner?.toBuilder();
      _track = $v.track?.toBuilder();
      _trackToken = $v.trackToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackLoginResponse other) {
    _$v = other as _$TrackLoginResponse;
  }

  @override
  void update(void Function(TrackLoginResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackLoginResponse build() => _build();

  _$TrackLoginResponse _build() {
    _$TrackLoginResponse _$result;
    try {
      _$result = _$v ??
          _$TrackLoginResponse._(
            corner: _corner?.build(),
            track: _track?.build(),
            trackToken: trackToken,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'corner';
        _corner?.build();
        _$failedField = 'track';
        _track?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TrackLoginResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
