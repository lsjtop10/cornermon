// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camp_report_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CampReportResponse extends CampReportResponse {
  @override
  final String? campId;
  @override
  final BuiltList<CornerStatsResponse>? cornerStats;
  @override
  final DateTime? generatedAt;
  @override
  final BuiltList<GroupStatsResponse>? groupStats;
  @override
  final JsonObject? operationalStats;
  @override
  final CampSummaryStatsResponse? summary;
  @override
  final JsonObject? timeline;
  @override
  final BuiltList<TrackStatsResponse>? trackStats;

  factory _$CampReportResponse(
          [void Function(CampReportResponseBuilder)? updates]) =>
      (CampReportResponseBuilder()..update(updates))._build();

  _$CampReportResponse._(
      {this.campId,
      this.cornerStats,
      this.generatedAt,
      this.groupStats,
      this.operationalStats,
      this.summary,
      this.timeline,
      this.trackStats})
      : super._();
  @override
  CampReportResponse rebuild(
          void Function(CampReportResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CampReportResponseBuilder toBuilder() =>
      CampReportResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CampReportResponse &&
        campId == other.campId &&
        cornerStats == other.cornerStats &&
        generatedAt == other.generatedAt &&
        groupStats == other.groupStats &&
        operationalStats == other.operationalStats &&
        summary == other.summary &&
        timeline == other.timeline &&
        trackStats == other.trackStats;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, campId.hashCode);
    _$hash = $jc(_$hash, cornerStats.hashCode);
    _$hash = $jc(_$hash, generatedAt.hashCode);
    _$hash = $jc(_$hash, groupStats.hashCode);
    _$hash = $jc(_$hash, operationalStats.hashCode);
    _$hash = $jc(_$hash, summary.hashCode);
    _$hash = $jc(_$hash, timeline.hashCode);
    _$hash = $jc(_$hash, trackStats.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CampReportResponse')
          ..add('campId', campId)
          ..add('cornerStats', cornerStats)
          ..add('generatedAt', generatedAt)
          ..add('groupStats', groupStats)
          ..add('operationalStats', operationalStats)
          ..add('summary', summary)
          ..add('timeline', timeline)
          ..add('trackStats', trackStats))
        .toString();
  }
}

class CampReportResponseBuilder
    implements Builder<CampReportResponse, CampReportResponseBuilder> {
  _$CampReportResponse? _$v;

  String? _campId;
  String? get campId => _$this._campId;
  set campId(String? campId) => _$this._campId = campId;

  ListBuilder<CornerStatsResponse>? _cornerStats;
  ListBuilder<CornerStatsResponse> get cornerStats =>
      _$this._cornerStats ??= ListBuilder<CornerStatsResponse>();
  set cornerStats(ListBuilder<CornerStatsResponse>? cornerStats) =>
      _$this._cornerStats = cornerStats;

  DateTime? _generatedAt;
  DateTime? get generatedAt => _$this._generatedAt;
  set generatedAt(DateTime? generatedAt) => _$this._generatedAt = generatedAt;

  ListBuilder<GroupStatsResponse>? _groupStats;
  ListBuilder<GroupStatsResponse> get groupStats =>
      _$this._groupStats ??= ListBuilder<GroupStatsResponse>();
  set groupStats(ListBuilder<GroupStatsResponse>? groupStats) =>
      _$this._groupStats = groupStats;

  JsonObject? _operationalStats;
  JsonObject? get operationalStats => _$this._operationalStats;
  set operationalStats(JsonObject? operationalStats) =>
      _$this._operationalStats = operationalStats;

  CampSummaryStatsResponseBuilder? _summary;
  CampSummaryStatsResponseBuilder get summary =>
      _$this._summary ??= CampSummaryStatsResponseBuilder();
  set summary(CampSummaryStatsResponseBuilder? summary) =>
      _$this._summary = summary;

  JsonObject? _timeline;
  JsonObject? get timeline => _$this._timeline;
  set timeline(JsonObject? timeline) => _$this._timeline = timeline;

  ListBuilder<TrackStatsResponse>? _trackStats;
  ListBuilder<TrackStatsResponse> get trackStats =>
      _$this._trackStats ??= ListBuilder<TrackStatsResponse>();
  set trackStats(ListBuilder<TrackStatsResponse>? trackStats) =>
      _$this._trackStats = trackStats;

  CampReportResponseBuilder() {
    CampReportResponse._defaults(this);
  }

  CampReportResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _campId = $v.campId;
      _cornerStats = $v.cornerStats?.toBuilder();
      _generatedAt = $v.generatedAt;
      _groupStats = $v.groupStats?.toBuilder();
      _operationalStats = $v.operationalStats;
      _summary = $v.summary?.toBuilder();
      _timeline = $v.timeline;
      _trackStats = $v.trackStats?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CampReportResponse other) {
    _$v = other as _$CampReportResponse;
  }

  @override
  void update(void Function(CampReportResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CampReportResponse build() => _build();

  _$CampReportResponse _build() {
    _$CampReportResponse _$result;
    try {
      _$result = _$v ??
          _$CampReportResponse._(
            campId: campId,
            cornerStats: _cornerStats?.build(),
            generatedAt: generatedAt,
            groupStats: _groupStats?.build(),
            operationalStats: operationalStats,
            summary: _summary?.build(),
            timeline: timeline,
            trackStats: _trackStats?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'cornerStats';
        _cornerStats?.build();

        _$failedField = 'groupStats';
        _groupStats?.build();

        _$failedField = 'summary';
        _summary?.build();

        _$failedField = 'trackStats';
        _trackStats?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CampReportResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
