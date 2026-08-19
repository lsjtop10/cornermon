// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_message_count_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackMessageCountResponse extends TrackMessageCountResponse {
  @override
  final int? count;
  @override
  final String? trackId;
  @override
  final String? trackLabel;

  factory _$TrackMessageCountResponse(
          [void Function(TrackMessageCountResponseBuilder)? updates]) =>
      (TrackMessageCountResponseBuilder()..update(updates))._build();

  _$TrackMessageCountResponse._({this.count, this.trackId, this.trackLabel})
      : super._();
  @override
  TrackMessageCountResponse rebuild(
          void Function(TrackMessageCountResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackMessageCountResponseBuilder toBuilder() =>
      TrackMessageCountResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackMessageCountResponse &&
        count == other.count &&
        trackId == other.trackId &&
        trackLabel == other.trackLabel;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jc(_$hash, trackId.hashCode);
    _$hash = $jc(_$hash, trackLabel.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackMessageCountResponse')
          ..add('count', count)
          ..add('trackId', trackId)
          ..add('trackLabel', trackLabel))
        .toString();
  }
}

class TrackMessageCountResponseBuilder
    implements
        Builder<TrackMessageCountResponse, TrackMessageCountResponseBuilder> {
  _$TrackMessageCountResponse? _$v;

  int? _count;
  int? get count => _$this._count;
  set count(int? count) => _$this._count = count;

  String? _trackId;
  String? get trackId => _$this._trackId;
  set trackId(String? trackId) => _$this._trackId = trackId;

  String? _trackLabel;
  String? get trackLabel => _$this._trackLabel;
  set trackLabel(String? trackLabel) => _$this._trackLabel = trackLabel;

  TrackMessageCountResponseBuilder() {
    TrackMessageCountResponse._defaults(this);
  }

  TrackMessageCountResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _count = $v.count;
      _trackId = $v.trackId;
      _trackLabel = $v.trackLabel;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackMessageCountResponse other) {
    _$v = other as _$TrackMessageCountResponse;
  }

  @override
  void update(void Function(TrackMessageCountResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackMessageCountResponse build() => _build();

  _$TrackMessageCountResponse _build() {
    final _$result = _$v ??
        _$TrackMessageCountResponse._(
          count: count,
          trackId: trackId,
          trackLabel: trackLabel,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
