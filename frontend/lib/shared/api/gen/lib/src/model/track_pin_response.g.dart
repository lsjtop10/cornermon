// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_pin_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackPinResponse extends TrackPinResponse {
  @override
  final String? pin;
  @override
  final TrackResponse? track;

  factory _$TrackPinResponse(
          [void Function(TrackPinResponseBuilder)? updates]) =>
      (TrackPinResponseBuilder()..update(updates))._build();

  _$TrackPinResponse._({this.pin, this.track}) : super._();
  @override
  TrackPinResponse rebuild(void Function(TrackPinResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackPinResponseBuilder toBuilder() =>
      TrackPinResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackPinResponse &&
        pin == other.pin &&
        track == other.track;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pin.hashCode);
    _$hash = $jc(_$hash, track.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackPinResponse')
          ..add('pin', pin)
          ..add('track', track))
        .toString();
  }
}

class TrackPinResponseBuilder
    implements Builder<TrackPinResponse, TrackPinResponseBuilder> {
  _$TrackPinResponse? _$v;

  String? _pin;
  String? get pin => _$this._pin;
  set pin(String? pin) => _$this._pin = pin;

  TrackResponseBuilder? _track;
  TrackResponseBuilder get track => _$this._track ??= TrackResponseBuilder();
  set track(TrackResponseBuilder? track) => _$this._track = track;

  TrackPinResponseBuilder() {
    TrackPinResponse._defaults(this);
  }

  TrackPinResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pin = $v.pin;
      _track = $v.track?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackPinResponse other) {
    _$v = other as _$TrackPinResponse;
  }

  @override
  void update(void Function(TrackPinResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackPinResponse build() => _build();

  _$TrackPinResponse _build() {
    _$TrackPinResponse _$result;
    try {
      _$result = _$v ??
          _$TrackPinResponse._(
            pin: pin,
            track: _track?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'track';
        _track?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TrackPinResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
