// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corner_stats_track_throughputs_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CornerStatsTrackThroughputsInner
    extends CornerStatsTrackThroughputsInner {
  @override
  final String? trackId;
  @override
  final int? completedVisitCount;
  @override
  final num? avgDurationSeconds;

  factory _$CornerStatsTrackThroughputsInner(
          [void Function(CornerStatsTrackThroughputsInnerBuilder)? updates]) =>
      (CornerStatsTrackThroughputsInnerBuilder()..update(updates))._build();

  _$CornerStatsTrackThroughputsInner._(
      {this.trackId, this.completedVisitCount, this.avgDurationSeconds})
      : super._();
  @override
  CornerStatsTrackThroughputsInner rebuild(
          void Function(CornerStatsTrackThroughputsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CornerStatsTrackThroughputsInnerBuilder toBuilder() =>
      CornerStatsTrackThroughputsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CornerStatsTrackThroughputsInner &&
        trackId == other.trackId &&
        completedVisitCount == other.completedVisitCount &&
        avgDurationSeconds == other.avgDurationSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, trackId.hashCode);
    _$hash = $jc(_$hash, completedVisitCount.hashCode);
    _$hash = $jc(_$hash, avgDurationSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CornerStatsTrackThroughputsInner')
          ..add('trackId', trackId)
          ..add('completedVisitCount', completedVisitCount)
          ..add('avgDurationSeconds', avgDurationSeconds))
        .toString();
  }
}

class CornerStatsTrackThroughputsInnerBuilder
    implements
        Builder<CornerStatsTrackThroughputsInner,
            CornerStatsTrackThroughputsInnerBuilder> {
  _$CornerStatsTrackThroughputsInner? _$v;

  String? _trackId;
  String? get trackId => _$this._trackId;
  set trackId(String? trackId) => _$this._trackId = trackId;

  int? _completedVisitCount;
  int? get completedVisitCount => _$this._completedVisitCount;
  set completedVisitCount(int? completedVisitCount) =>
      _$this._completedVisitCount = completedVisitCount;

  num? _avgDurationSeconds;
  num? get avgDurationSeconds => _$this._avgDurationSeconds;
  set avgDurationSeconds(num? avgDurationSeconds) =>
      _$this._avgDurationSeconds = avgDurationSeconds;

  CornerStatsTrackThroughputsInnerBuilder() {
    CornerStatsTrackThroughputsInner._defaults(this);
  }

  CornerStatsTrackThroughputsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _trackId = $v.trackId;
      _completedVisitCount = $v.completedVisitCount;
      _avgDurationSeconds = $v.avgDurationSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CornerStatsTrackThroughputsInner other) {
    _$v = other as _$CornerStatsTrackThroughputsInner;
  }

  @override
  void update(void Function(CornerStatsTrackThroughputsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CornerStatsTrackThroughputsInner build() => _build();

  _$CornerStatsTrackThroughputsInner _build() {
    final _$result = _$v ??
        _$CornerStatsTrackThroughputsInner._(
          trackId: trackId,
          completedVisitCount: completedVisitCount,
          avgDurationSeconds: avgDurationSeconds,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
