// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_stats.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackStats extends TrackStats {
  @override
  final String? trackId;
  @override
  final String? cornerId;
  @override
  final int? trackNo;
  @override
  final DateTime? lifecycleStart;
  @override
  final DateTime? lifecycleEnd;
  @override
  final int? completedVisitCount;
  @override
  final num? avgDurationSeconds;
  @override
  final int? pinLoginFailureCount;

  factory _$TrackStats([void Function(TrackStatsBuilder)? updates]) =>
      (TrackStatsBuilder()..update(updates))._build();

  _$TrackStats._({
    this.trackId,
    this.cornerId,
    this.trackNo,
    this.lifecycleStart,
    this.lifecycleEnd,
    this.completedVisitCount,
    this.avgDurationSeconds,
    this.pinLoginFailureCount,
  }) : super._();
  @override
  TrackStats rebuild(void Function(TrackStatsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackStatsBuilder toBuilder() => TrackStatsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackStats &&
        trackId == other.trackId &&
        cornerId == other.cornerId &&
        trackNo == other.trackNo &&
        lifecycleStart == other.lifecycleStart &&
        lifecycleEnd == other.lifecycleEnd &&
        completedVisitCount == other.completedVisitCount &&
        avgDurationSeconds == other.avgDurationSeconds &&
        pinLoginFailureCount == other.pinLoginFailureCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, trackId.hashCode);
    _$hash = $jc(_$hash, cornerId.hashCode);
    _$hash = $jc(_$hash, trackNo.hashCode);
    _$hash = $jc(_$hash, lifecycleStart.hashCode);
    _$hash = $jc(_$hash, lifecycleEnd.hashCode);
    _$hash = $jc(_$hash, completedVisitCount.hashCode);
    _$hash = $jc(_$hash, avgDurationSeconds.hashCode);
    _$hash = $jc(_$hash, pinLoginFailureCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackStats')
          ..add('trackId', trackId)
          ..add('cornerId', cornerId)
          ..add('trackNo', trackNo)
          ..add('lifecycleStart', lifecycleStart)
          ..add('lifecycleEnd', lifecycleEnd)
          ..add('completedVisitCount', completedVisitCount)
          ..add('avgDurationSeconds', avgDurationSeconds)
          ..add('pinLoginFailureCount', pinLoginFailureCount))
        .toString();
  }
}

class TrackStatsBuilder implements Builder<TrackStats, TrackStatsBuilder> {
  _$TrackStats? _$v;

  String? _trackId;
  String? get trackId => _$this._trackId;
  set trackId(String? trackId) => _$this._trackId = trackId;

  String? _cornerId;
  String? get cornerId => _$this._cornerId;
  set cornerId(String? cornerId) => _$this._cornerId = cornerId;

  int? _trackNo;
  int? get trackNo => _$this._trackNo;
  set trackNo(int? trackNo) => _$this._trackNo = trackNo;

  DateTime? _lifecycleStart;
  DateTime? get lifecycleStart => _$this._lifecycleStart;
  set lifecycleStart(DateTime? lifecycleStart) =>
      _$this._lifecycleStart = lifecycleStart;

  DateTime? _lifecycleEnd;
  DateTime? get lifecycleEnd => _$this._lifecycleEnd;
  set lifecycleEnd(DateTime? lifecycleEnd) =>
      _$this._lifecycleEnd = lifecycleEnd;

  int? _completedVisitCount;
  int? get completedVisitCount => _$this._completedVisitCount;
  set completedVisitCount(int? completedVisitCount) =>
      _$this._completedVisitCount = completedVisitCount;

  num? _avgDurationSeconds;
  num? get avgDurationSeconds => _$this._avgDurationSeconds;
  set avgDurationSeconds(num? avgDurationSeconds) =>
      _$this._avgDurationSeconds = avgDurationSeconds;

  int? _pinLoginFailureCount;
  int? get pinLoginFailureCount => _$this._pinLoginFailureCount;
  set pinLoginFailureCount(int? pinLoginFailureCount) =>
      _$this._pinLoginFailureCount = pinLoginFailureCount;

  TrackStatsBuilder() {
    TrackStats._defaults(this);
  }

  TrackStatsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _trackId = $v.trackId;
      _cornerId = $v.cornerId;
      _trackNo = $v.trackNo;
      _lifecycleStart = $v.lifecycleStart;
      _lifecycleEnd = $v.lifecycleEnd;
      _completedVisitCount = $v.completedVisitCount;
      _avgDurationSeconds = $v.avgDurationSeconds;
      _pinLoginFailureCount = $v.pinLoginFailureCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackStats other) {
    _$v = other as _$TrackStats;
  }

  @override
  void update(void Function(TrackStatsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackStats build() => _build();

  _$TrackStats _build() {
    final _$result =
        _$v ??
        _$TrackStats._(
          trackId: trackId,
          cornerId: cornerId,
          trackNo: trackNo,
          lifecycleStart: lifecycleStart,
          lifecycleEnd: lifecycleEnd,
          completedVisitCount: completedVisitCount,
          avgDurationSeconds: avgDurationSeconds,
          pinLoginFailureCount: pinLoginFailureCount,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
