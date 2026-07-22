// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'camp_summary_stats_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CampSummaryStatsResponse extends CampSummaryStatsResponse {
  @override
  final num? avgDeviationSeconds;
  @override
  final BuiltList<BottleneckRankingResponse>? bottleneckRanking;
  @override
  final num? completionRate;
  @override
  final int? exceptionApprovalCount;
  @override
  final int? finishedGroupCount;
  @override
  final num? manualVisitRatio;
  @override
  final int? programDurationSeconds;
  @override
  final int? ruleOverrideCount;
  @override
  final int? totalGroups;
  @override
  final int? totalVisits;
  @override
  final int? trackOperationCount;
  @override
  final num? visitCompletionRate;

  factory _$CampSummaryStatsResponse(
          [void Function(CampSummaryStatsResponseBuilder)? updates]) =>
      (CampSummaryStatsResponseBuilder()..update(updates))._build();

  _$CampSummaryStatsResponse._(
      {this.avgDeviationSeconds,
      this.bottleneckRanking,
      this.completionRate,
      this.exceptionApprovalCount,
      this.finishedGroupCount,
      this.manualVisitRatio,
      this.programDurationSeconds,
      this.ruleOverrideCount,
      this.totalGroups,
      this.totalVisits,
      this.trackOperationCount,
      this.visitCompletionRate})
      : super._();
  @override
  CampSummaryStatsResponse rebuild(
          void Function(CampSummaryStatsResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CampSummaryStatsResponseBuilder toBuilder() =>
      CampSummaryStatsResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CampSummaryStatsResponse &&
        avgDeviationSeconds == other.avgDeviationSeconds &&
        bottleneckRanking == other.bottleneckRanking &&
        completionRate == other.completionRate &&
        exceptionApprovalCount == other.exceptionApprovalCount &&
        finishedGroupCount == other.finishedGroupCount &&
        manualVisitRatio == other.manualVisitRatio &&
        programDurationSeconds == other.programDurationSeconds &&
        ruleOverrideCount == other.ruleOverrideCount &&
        totalGroups == other.totalGroups &&
        totalVisits == other.totalVisits &&
        trackOperationCount == other.trackOperationCount &&
        visitCompletionRate == other.visitCompletionRate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, avgDeviationSeconds.hashCode);
    _$hash = $jc(_$hash, bottleneckRanking.hashCode);
    _$hash = $jc(_$hash, completionRate.hashCode);
    _$hash = $jc(_$hash, exceptionApprovalCount.hashCode);
    _$hash = $jc(_$hash, finishedGroupCount.hashCode);
    _$hash = $jc(_$hash, manualVisitRatio.hashCode);
    _$hash = $jc(_$hash, programDurationSeconds.hashCode);
    _$hash = $jc(_$hash, ruleOverrideCount.hashCode);
    _$hash = $jc(_$hash, totalGroups.hashCode);
    _$hash = $jc(_$hash, totalVisits.hashCode);
    _$hash = $jc(_$hash, trackOperationCount.hashCode);
    _$hash = $jc(_$hash, visitCompletionRate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CampSummaryStatsResponse')
          ..add('avgDeviationSeconds', avgDeviationSeconds)
          ..add('bottleneckRanking', bottleneckRanking)
          ..add('completionRate', completionRate)
          ..add('exceptionApprovalCount', exceptionApprovalCount)
          ..add('finishedGroupCount', finishedGroupCount)
          ..add('manualVisitRatio', manualVisitRatio)
          ..add('programDurationSeconds', programDurationSeconds)
          ..add('ruleOverrideCount', ruleOverrideCount)
          ..add('totalGroups', totalGroups)
          ..add('totalVisits', totalVisits)
          ..add('trackOperationCount', trackOperationCount)
          ..add('visitCompletionRate', visitCompletionRate))
        .toString();
  }
}

class CampSummaryStatsResponseBuilder
    implements
        Builder<CampSummaryStatsResponse, CampSummaryStatsResponseBuilder> {
  _$CampSummaryStatsResponse? _$v;

  num? _avgDeviationSeconds;
  num? get avgDeviationSeconds => _$this._avgDeviationSeconds;
  set avgDeviationSeconds(num? avgDeviationSeconds) =>
      _$this._avgDeviationSeconds = avgDeviationSeconds;

  ListBuilder<BottleneckRankingResponse>? _bottleneckRanking;
  ListBuilder<BottleneckRankingResponse> get bottleneckRanking =>
      _$this._bottleneckRanking ??= ListBuilder<BottleneckRankingResponse>();
  set bottleneckRanking(
          ListBuilder<BottleneckRankingResponse>? bottleneckRanking) =>
      _$this._bottleneckRanking = bottleneckRanking;

  num? _completionRate;
  num? get completionRate => _$this._completionRate;
  set completionRate(num? completionRate) =>
      _$this._completionRate = completionRate;

  int? _exceptionApprovalCount;
  int? get exceptionApprovalCount => _$this._exceptionApprovalCount;
  set exceptionApprovalCount(int? exceptionApprovalCount) =>
      _$this._exceptionApprovalCount = exceptionApprovalCount;

  int? _finishedGroupCount;
  int? get finishedGroupCount => _$this._finishedGroupCount;
  set finishedGroupCount(int? finishedGroupCount) =>
      _$this._finishedGroupCount = finishedGroupCount;

  num? _manualVisitRatio;
  num? get manualVisitRatio => _$this._manualVisitRatio;
  set manualVisitRatio(num? manualVisitRatio) =>
      _$this._manualVisitRatio = manualVisitRatio;

  int? _programDurationSeconds;
  int? get programDurationSeconds => _$this._programDurationSeconds;
  set programDurationSeconds(int? programDurationSeconds) =>
      _$this._programDurationSeconds = programDurationSeconds;

  int? _ruleOverrideCount;
  int? get ruleOverrideCount => _$this._ruleOverrideCount;
  set ruleOverrideCount(int? ruleOverrideCount) =>
      _$this._ruleOverrideCount = ruleOverrideCount;

  int? _totalGroups;
  int? get totalGroups => _$this._totalGroups;
  set totalGroups(int? totalGroups) => _$this._totalGroups = totalGroups;

  int? _totalVisits;
  int? get totalVisits => _$this._totalVisits;
  set totalVisits(int? totalVisits) => _$this._totalVisits = totalVisits;

  int? _trackOperationCount;
  int? get trackOperationCount => _$this._trackOperationCount;
  set trackOperationCount(int? trackOperationCount) =>
      _$this._trackOperationCount = trackOperationCount;

  num? _visitCompletionRate;
  num? get visitCompletionRate => _$this._visitCompletionRate;
  set visitCompletionRate(num? visitCompletionRate) =>
      _$this._visitCompletionRate = visitCompletionRate;

  CampSummaryStatsResponseBuilder() {
    CampSummaryStatsResponse._defaults(this);
  }

  CampSummaryStatsResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _avgDeviationSeconds = $v.avgDeviationSeconds;
      _bottleneckRanking = $v.bottleneckRanking?.toBuilder();
      _completionRate = $v.completionRate;
      _exceptionApprovalCount = $v.exceptionApprovalCount;
      _finishedGroupCount = $v.finishedGroupCount;
      _manualVisitRatio = $v.manualVisitRatio;
      _programDurationSeconds = $v.programDurationSeconds;
      _ruleOverrideCount = $v.ruleOverrideCount;
      _totalGroups = $v.totalGroups;
      _totalVisits = $v.totalVisits;
      _trackOperationCount = $v.trackOperationCount;
      _visitCompletionRate = $v.visitCompletionRate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CampSummaryStatsResponse other) {
    _$v = other as _$CampSummaryStatsResponse;
  }

  @override
  void update(void Function(CampSummaryStatsResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CampSummaryStatsResponse build() => _build();

  _$CampSummaryStatsResponse _build() {
    _$CampSummaryStatsResponse _$result;
    try {
      _$result = _$v ??
          _$CampSummaryStatsResponse._(
            avgDeviationSeconds: avgDeviationSeconds,
            bottleneckRanking: _bottleneckRanking?.build(),
            completionRate: completionRate,
            exceptionApprovalCount: exceptionApprovalCount,
            finishedGroupCount: finishedGroupCount,
            manualVisitRatio: manualVisitRatio,
            programDurationSeconds: programDurationSeconds,
            ruleOverrideCount: ruleOverrideCount,
            totalGroups: totalGroups,
            totalVisits: totalVisits,
            trackOperationCount: trackOperationCount,
            visitCompletionRate: visitCompletionRate,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'bottleneckRanking';
        _bottleneckRanking?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CampSummaryStatsResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
