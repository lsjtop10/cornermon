// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_tracks_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExportTracksResponse extends ExportTracksResponse {
  @override
  final BuiltList<TrackPinResponse>? tracks;

  factory _$ExportTracksResponse(
          [void Function(ExportTracksResponseBuilder)? updates]) =>
      (ExportTracksResponseBuilder()..update(updates))._build();

  _$ExportTracksResponse._({this.tracks}) : super._();
  @override
  ExportTracksResponse rebuild(
          void Function(ExportTracksResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExportTracksResponseBuilder toBuilder() =>
      ExportTracksResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExportTracksResponse && tracks == other.tracks;
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
    return (newBuiltValueToStringHelper(r'ExportTracksResponse')
          ..add('tracks', tracks))
        .toString();
  }
}

class ExportTracksResponseBuilder
    implements Builder<ExportTracksResponse, ExportTracksResponseBuilder> {
  _$ExportTracksResponse? _$v;

  ListBuilder<TrackPinResponse>? _tracks;
  ListBuilder<TrackPinResponse> get tracks =>
      _$this._tracks ??= ListBuilder<TrackPinResponse>();
  set tracks(ListBuilder<TrackPinResponse>? tracks) => _$this._tracks = tracks;

  ExportTracksResponseBuilder() {
    ExportTracksResponse._defaults(this);
  }

  ExportTracksResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tracks = $v.tracks?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExportTracksResponse other) {
    _$v = other as _$ExportTracksResponse;
  }

  @override
  void update(void Function(ExportTracksResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExportTracksResponse build() => _build();

  _$ExportTracksResponse _build() {
    _$ExportTracksResponse _$result;
    try {
      _$result = _$v ??
          _$ExportTracksResponse._(
            tracks: _tracks?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tracks';
        _tracks?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ExportTracksResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
