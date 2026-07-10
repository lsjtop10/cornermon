// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_sse_snapshot.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackSseSnapshot extends TrackSseSnapshot {
  @override
  final Track? track;
  @override
  final Corner? corner;
  @override
  final VisitSummary? currentVisit;
  @override
  final int? unreadBroadcastCount;

  factory _$TrackSseSnapshot([
    void Function(TrackSseSnapshotBuilder)? updates,
  ]) => (TrackSseSnapshotBuilder()..update(updates))._build();

  _$TrackSseSnapshot._({
    this.track,
    this.corner,
    this.currentVisit,
    this.unreadBroadcastCount,
  }) : super._();
  @override
  TrackSseSnapshot rebuild(void Function(TrackSseSnapshotBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackSseSnapshotBuilder toBuilder() =>
      TrackSseSnapshotBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackSseSnapshot &&
        track == other.track &&
        corner == other.corner &&
        currentVisit == other.currentVisit &&
        unreadBroadcastCount == other.unreadBroadcastCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, track.hashCode);
    _$hash = $jc(_$hash, corner.hashCode);
    _$hash = $jc(_$hash, currentVisit.hashCode);
    _$hash = $jc(_$hash, unreadBroadcastCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackSseSnapshot')
          ..add('track', track)
          ..add('corner', corner)
          ..add('currentVisit', currentVisit)
          ..add('unreadBroadcastCount', unreadBroadcastCount))
        .toString();
  }
}

class TrackSseSnapshotBuilder
    implements Builder<TrackSseSnapshot, TrackSseSnapshotBuilder> {
  _$TrackSseSnapshot? _$v;

  TrackBuilder? _track;
  TrackBuilder get track => _$this._track ??= TrackBuilder();
  set track(TrackBuilder? track) => _$this._track = track;

  CornerBuilder? _corner;
  CornerBuilder get corner => _$this._corner ??= CornerBuilder();
  set corner(CornerBuilder? corner) => _$this._corner = corner;

  VisitSummaryBuilder? _currentVisit;
  VisitSummaryBuilder get currentVisit =>
      _$this._currentVisit ??= VisitSummaryBuilder();
  set currentVisit(VisitSummaryBuilder? currentVisit) =>
      _$this._currentVisit = currentVisit;

  int? _unreadBroadcastCount;
  int? get unreadBroadcastCount => _$this._unreadBroadcastCount;
  set unreadBroadcastCount(int? unreadBroadcastCount) =>
      _$this._unreadBroadcastCount = unreadBroadcastCount;

  TrackSseSnapshotBuilder() {
    TrackSseSnapshot._defaults(this);
  }

  TrackSseSnapshotBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _track = $v.track?.toBuilder();
      _corner = $v.corner?.toBuilder();
      _currentVisit = $v.currentVisit?.toBuilder();
      _unreadBroadcastCount = $v.unreadBroadcastCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackSseSnapshot other) {
    _$v = other as _$TrackSseSnapshot;
  }

  @override
  void update(void Function(TrackSseSnapshotBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackSseSnapshot build() => _build();

  _$TrackSseSnapshot _build() {
    _$TrackSseSnapshot _$result;
    try {
      _$result =
          _$v ??
          _$TrackSseSnapshot._(
            track: _track?.build(),
            corner: _corner?.build(),
            currentVisit: _currentVisit?.build(),
            unreadBroadcastCount: unreadBroadcastCount,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'track';
        _track?.build();
        _$failedField = 'corner';
        _corner?.build();
        _$failedField = 'currentVisit';
        _currentVisit?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'TrackSseSnapshot',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
