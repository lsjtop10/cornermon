// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracks_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TracksGet200Response extends TracksGet200Response {
  @override
  final BuiltList<Track>? tracks;

  factory _$TracksGet200Response(
          [void Function(TracksGet200ResponseBuilder)? updates]) =>
      (TracksGet200ResponseBuilder()..update(updates))._build();

  _$TracksGet200Response._({this.tracks}) : super._();
  @override
  TracksGet200Response rebuild(
          void Function(TracksGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TracksGet200ResponseBuilder toBuilder() =>
      TracksGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TracksGet200Response && tracks == other.tracks;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tracks.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TracksGet200Response')
          ..add('tracks', tracks))
        .toString();
  }
}

class TracksGet200ResponseBuilder
    implements Builder<TracksGet200Response, TracksGet200ResponseBuilder> {
  _$TracksGet200Response? _$v;

  ListBuilder<Track>? _tracks;
  ListBuilder<Track> get tracks => _$this._tracks ??= ListBuilder<Track>();
  set tracks(ListBuilder<Track>? tracks) => _$this._tracks = tracks;

  TracksGet200ResponseBuilder() {
    TracksGet200Response._defaults(this);
  }

  TracksGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tracks = $v.tracks?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TracksGet200Response other) {
    _$v = other as _$TracksGet200Response;
  }

  @override
  void update(void Function(TracksGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TracksGet200Response build() => _build();

  _$TracksGet200Response _build() {
    _$TracksGet200Response _$result;
    try {
      _$result = _$v ??
          _$TracksGet200Response._(
            tracks: _tracks?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tracks';
        _tracks?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TracksGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
