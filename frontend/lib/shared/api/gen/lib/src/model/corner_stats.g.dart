// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corner_stats.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CornerStats extends CornerStats {
  @override
  final String? cornerId;
  @override
  final String? cornerName;
  @override
  final int? completedVisitCount;
  @override
  final BuiltList<CornerStatsUnvisitedGroupsInner>? unvisitedGroups;
  @override
  final num? avgDurationSeconds;
  @override
  final num? medianDurationSeconds;
  @override
  final num? stddevDurationSeconds;
  @override
  final num? avgDeviationSeconds;
  @override
  final double? positiveDeviationRatio;
  @override
  final int? busyDurationSeconds;
  @override
  final int? idleDurationSeconds;
  @override
  final int? inactiveDurationSeconds;
  @override
  final BuiltList<CornerStatsTrackThroughputsInner>? trackThroughputs;

  factory _$CornerStats([void Function(CornerStatsBuilder)? updates]) =>
      (CornerStatsBuilder()..update(updates))._build();

  _$CornerStats._({
    this.cornerId,
    this.cornerName,
    this.completedVisitCount,
    this.unvisitedGroups,
    this.avgDurationSeconds,
    this.medianDurationSeconds,
    this.stddevDurationSeconds,
    this.avgDeviationSeconds,
    this.positiveDeviationRatio,
    this.busyDurationSeconds,
    this.idleDurationSeconds,
    this.inactiveDurationSeconds,
    this.trackThroughputs,
  }) : super._();
  @override
  CornerStats rebuild(void Function(CornerStatsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CornerStatsBuilder toBuilder() => CornerStatsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CornerStats &&
        cornerId == other.cornerId &&
        cornerName == other.cornerName &&
        completedVisitCount == other.completedVisitCount &&
        unvisitedGroups == other.unvisitedGroups &&
        avgDurationSeconds == other.avgDurationSeconds &&
        medianDurationSeconds == other.medianDurationSeconds &&
        stddevDurationSeconds == other.stddevDurationSeconds &&
        avgDeviationSeconds == other.avgDeviationSeconds &&
        positiveDeviationRatio == other.positiveDeviationRatio &&
        busyDurationSeconds == other.busyDurationSeconds &&
        idleDurationSeconds == other.idleDurationSeconds &&
        inactiveDurationSeconds == other.inactiveDurationSeconds &&
        trackThroughputs == other.trackThroughputs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cornerId.hashCode);
    _$hash = $jc(_$hash, cornerName.hashCode);
    _$hash = $jc(_$hash, completedVisitCount.hashCode);
    _$hash = $jc(_$hash, unvisitedGroups.hashCode);
    _$hash = $jc(_$hash, avgDurationSeconds.hashCode);
    _$hash = $jc(_$hash, medianDurationSeconds.hashCode);
    _$hash = $jc(_$hash, stddevDurationSeconds.hashCode);
    _$hash = $jc(_$hash, avgDeviationSeconds.hashCode);
    _$hash = $jc(_$hash, positiveDeviationRatio.hashCode);
    _$hash = $jc(_$hash, busyDurationSeconds.hashCode);
    _$hash = $jc(_$hash, idleDurationSeconds.hashCode);
    _$hash = $jc(_$hash, inactiveDurationSeconds.hashCode);
    _$hash = $jc(_$hash, trackThroughputs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CornerStats')
          ..add('cornerId', cornerId)
          ..add('cornerName', cornerName)
          ..add('completedVisitCount', completedVisitCount)
          ..add('unvisitedGroups', unvisitedGroups)
          ..add('avgDurationSeconds', avgDurationSeconds)
          ..add('medianDurationSeconds', medianDurationSeconds)
          ..add('stddevDurationSeconds', stddevDurationSeconds)
          ..add('avgDeviationSeconds', avgDeviationSeconds)
          ..add('positiveDeviationRatio', positiveDeviationRatio)
          ..add('busyDurationSeconds', busyDurationSeconds)
          ..add('idleDurationSeconds', idleDurationSeconds)
          ..add('inactiveDurationSeconds', inactiveDurationSeconds)
          ..add('trackThroughputs', trackThroughputs))
        .toString();
  }
}

class CornerStatsBuilder implements Builder<CornerStats, CornerStatsBuilder> {
  _$CornerStats? _$v;

  String? _cornerId;
  String? get cornerId => _$this._cornerId;
  set cornerId(String? cornerId) => _$this._cornerId = cornerId;

  String? _cornerName;
  String? get cornerName => _$this._cornerName;
  set cornerName(String? cornerName) => _$this._cornerName = cornerName;

  int? _completedVisitCount;
  int? get completedVisitCount => _$this._completedVisitCount;
  set completedVisitCount(int? completedVisitCount) =>
      _$this._completedVisitCount = completedVisitCount;

  ListBuilder<CornerStatsUnvisitedGroupsInner>? _unvisitedGroups;
  ListBuilder<CornerStatsUnvisitedGroupsInner> get unvisitedGroups =>
      _$this._unvisitedGroups ??=
          ListBuilder<CornerStatsUnvisitedGroupsInner>();
  set unvisitedGroups(
    ListBuilder<CornerStatsUnvisitedGroupsInner>? unvisitedGroups,
  ) => _$this._unvisitedGroups = unvisitedGroups;

  num? _avgDurationSeconds;
  num? get avgDurationSeconds => _$this._avgDurationSeconds;
  set avgDurationSeconds(num? avgDurationSeconds) =>
      _$this._avgDurationSeconds = avgDurationSeconds;

  num? _medianDurationSeconds;
  num? get medianDurationSeconds => _$this._medianDurationSeconds;
  set medianDurationSeconds(num? medianDurationSeconds) =>
      _$this._medianDurationSeconds = medianDurationSeconds;

  num? _stddevDurationSeconds;
  num? get stddevDurationSeconds => _$this._stddevDurationSeconds;
  set stddevDurationSeconds(num? stddevDurationSeconds) =>
      _$this._stddevDurationSeconds = stddevDurationSeconds;

  num? _avgDeviationSeconds;
  num? get avgDeviationSeconds => _$this._avgDeviationSeconds;
  set avgDeviationSeconds(num? avgDeviationSeconds) =>
      _$this._avgDeviationSeconds = avgDeviationSeconds;

  double? _positiveDeviationRatio;
  double? get positiveDeviationRatio => _$this._positiveDeviationRatio;
  set positiveDeviationRatio(double? positiveDeviationRatio) =>
      _$this._positiveDeviationRatio = positiveDeviationRatio;

  int? _busyDurationSeconds;
  int? get busyDurationSeconds => _$this._busyDurationSeconds;
  set busyDurationSeconds(int? busyDurationSeconds) =>
      _$this._busyDurationSeconds = busyDurationSeconds;

  int? _idleDurationSeconds;
  int? get idleDurationSeconds => _$this._idleDurationSeconds;
  set idleDurationSeconds(int? idleDurationSeconds) =>
      _$this._idleDurationSeconds = idleDurationSeconds;

  int? _inactiveDurationSeconds;
  int? get inactiveDurationSeconds => _$this._inactiveDurationSeconds;
  set inactiveDurationSeconds(int? inactiveDurationSeconds) =>
      _$this._inactiveDurationSeconds = inactiveDurationSeconds;

  ListBuilder<CornerStatsTrackThroughputsInner>? _trackThroughputs;
  ListBuilder<CornerStatsTrackThroughputsInner> get trackThroughputs =>
      _$this._trackThroughputs ??=
          ListBuilder<CornerStatsTrackThroughputsInner>();
  set trackThroughputs(
    ListBuilder<CornerStatsTrackThroughputsInner>? trackThroughputs,
  ) => _$this._trackThroughputs = trackThroughputs;

  CornerStatsBuilder() {
    CornerStats._defaults(this);
  }

  CornerStatsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cornerId = $v.cornerId;
      _cornerName = $v.cornerName;
      _completedVisitCount = $v.completedVisitCount;
      _unvisitedGroups = $v.unvisitedGroups?.toBuilder();
      _avgDurationSeconds = $v.avgDurationSeconds;
      _medianDurationSeconds = $v.medianDurationSeconds;
      _stddevDurationSeconds = $v.stddevDurationSeconds;
      _avgDeviationSeconds = $v.avgDeviationSeconds;
      _positiveDeviationRatio = $v.positiveDeviationRatio;
      _busyDurationSeconds = $v.busyDurationSeconds;
      _idleDurationSeconds = $v.idleDurationSeconds;
      _inactiveDurationSeconds = $v.inactiveDurationSeconds;
      _trackThroughputs = $v.trackThroughputs?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CornerStats other) {
    _$v = other as _$CornerStats;
  }

  @override
  void update(void Function(CornerStatsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CornerStats build() => _build();

  _$CornerStats _build() {
    _$CornerStats _$result;
    try {
      _$result =
          _$v ??
          _$CornerStats._(
            cornerId: cornerId,
            cornerName: cornerName,
            completedVisitCount: completedVisitCount,
            unvisitedGroups: _unvisitedGroups?.build(),
            avgDurationSeconds: avgDurationSeconds,
            medianDurationSeconds: medianDurationSeconds,
            stddevDurationSeconds: stddevDurationSeconds,
            avgDeviationSeconds: avgDeviationSeconds,
            positiveDeviationRatio: positiveDeviationRatio,
            busyDurationSeconds: busyDurationSeconds,
            idleDurationSeconds: idleDurationSeconds,
            inactiveDurationSeconds: inactiveDurationSeconds,
            trackThroughputs: _trackThroughputs?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'unvisitedGroups';
        _unvisitedGroups?.build();

        _$failedField = 'trackThroughputs';
        _trackThroughputs?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'CornerStats',
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
