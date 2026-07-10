// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camp_report.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CampReport extends CampReport {
  @override
  final String campId;
  @override
  final DateTime generatedAt;
  @override
  final CampSummaryStats summary;
  @override
  final BuiltList<CornerStats> cornerStats;
  @override
  final BuiltList<TrackStats>? trackStats;
  @override
  final BuiltList<GroupStats> groupStats;
  @override
  final TimelineStats? timeline;
  @override
  final OperationalStats? operationalStats;

  factory _$CampReport([void Function(CampReportBuilder)? updates]) =>
      (CampReportBuilder()..update(updates))._build();

  _$CampReport._({
    required this.campId,
    required this.generatedAt,
    required this.summary,
    required this.cornerStats,
    this.trackStats,
    required this.groupStats,
    this.timeline,
    this.operationalStats,
  }) : super._();
  @override
  CampReport rebuild(void Function(CampReportBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CampReportBuilder toBuilder() => CampReportBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CampReport &&
        campId == other.campId &&
        generatedAt == other.generatedAt &&
        summary == other.summary &&
        cornerStats == other.cornerStats &&
        trackStats == other.trackStats &&
        groupStats == other.groupStats &&
        timeline == other.timeline &&
        operationalStats == other.operationalStats;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, campId.hashCode);
    _$hash = $jc(_$hash, generatedAt.hashCode);
    _$hash = $jc(_$hash, summary.hashCode);
    _$hash = $jc(_$hash, cornerStats.hashCode);
    _$hash = $jc(_$hash, trackStats.hashCode);
    _$hash = $jc(_$hash, groupStats.hashCode);
    _$hash = $jc(_$hash, timeline.hashCode);
    _$hash = $jc(_$hash, operationalStats.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CampReport')
          ..add('campId', campId)
          ..add('generatedAt', generatedAt)
          ..add('summary', summary)
          ..add('cornerStats', cornerStats)
          ..add('trackStats', trackStats)
          ..add('groupStats', groupStats)
          ..add('timeline', timeline)
          ..add('operationalStats', operationalStats))
        .toString();
  }
}

class CampReportBuilder implements Builder<CampReport, CampReportBuilder> {
  _$CampReport? _$v;

  String? _campId;
  String? get campId => _$this._campId;
  set campId(String? campId) => _$this._campId = campId;

  DateTime? _generatedAt;
  DateTime? get generatedAt => _$this._generatedAt;
  set generatedAt(DateTime? generatedAt) => _$this._generatedAt = generatedAt;

  CampSummaryStatsBuilder? _summary;
  CampSummaryStatsBuilder get summary =>
      _$this._summary ??= CampSummaryStatsBuilder();
  set summary(CampSummaryStatsBuilder? summary) => _$this._summary = summary;

  ListBuilder<CornerStats>? _cornerStats;
  ListBuilder<CornerStats> get cornerStats =>
      _$this._cornerStats ??= ListBuilder<CornerStats>();
  set cornerStats(ListBuilder<CornerStats>? cornerStats) =>
      _$this._cornerStats = cornerStats;

  ListBuilder<TrackStats>? _trackStats;
  ListBuilder<TrackStats> get trackStats =>
      _$this._trackStats ??= ListBuilder<TrackStats>();
  set trackStats(ListBuilder<TrackStats>? trackStats) =>
      _$this._trackStats = trackStats;

  ListBuilder<GroupStats>? _groupStats;
  ListBuilder<GroupStats> get groupStats =>
      _$this._groupStats ??= ListBuilder<GroupStats>();
  set groupStats(ListBuilder<GroupStats>? groupStats) =>
      _$this._groupStats = groupStats;

  TimelineStatsBuilder? _timeline;
  TimelineStatsBuilder get timeline =>
      _$this._timeline ??= TimelineStatsBuilder();
  set timeline(TimelineStatsBuilder? timeline) => _$this._timeline = timeline;

  OperationalStatsBuilder? _operationalStats;
  OperationalStatsBuilder get operationalStats =>
      _$this._operationalStats ??= OperationalStatsBuilder();
  set operationalStats(OperationalStatsBuilder? operationalStats) =>
      _$this._operationalStats = operationalStats;

  CampReportBuilder() {
    CampReport._defaults(this);
  }

  CampReportBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _campId = $v.campId;
      _generatedAt = $v.generatedAt;
      _summary = $v.summary.toBuilder();
      _cornerStats = $v.cornerStats.toBuilder();
      _trackStats = $v.trackStats?.toBuilder();
      _groupStats = $v.groupStats.toBuilder();
      _timeline = $v.timeline?.toBuilder();
      _operationalStats = $v.operationalStats?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CampReport other) {
    _$v = other as _$CampReport;
  }

  @override
  void update(void Function(CampReportBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CampReport build() => _build();

  _$CampReport _build() {
    _$CampReport _$result;
    try {
      _$result =
          _$v ??
          _$CampReport._(
            campId: BuiltValueNullFieldError.checkNotNull(
              campId,
              r'CampReport',
              'campId',
            ),
            generatedAt: BuiltValueNullFieldError.checkNotNull(
              generatedAt,
              r'CampReport',
              'generatedAt',
            ),
            summary: summary.build(),
            cornerStats: cornerStats.build(),
            trackStats: _trackStats?.build(),
            groupStats: groupStats.build(),
            timeline: _timeline?.build(),
            operationalStats: _operationalStats?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'summary';
        summary.build();
        _$failedField = 'cornerStats';
        cornerStats.build();
        _$failedField = 'trackStats';
        _trackStats?.build();
        _$failedField = 'groupStats';
        groupStats.build();
        _$failedField = 'timeline';
        _timeline?.build();
        _$failedField = 'operationalStats';
        _operationalStats?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'CampReport',
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
