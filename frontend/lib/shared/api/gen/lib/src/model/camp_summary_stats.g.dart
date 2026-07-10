// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camp_summary_stats.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CampSummaryStats extends CampSummaryStats {
  @override
  final int? totalGroups;
  @override
  final int? finishedGroupCount;
  @override
  final double? completionRate;
  @override
  final int? totalVisits;
  @override
  final double? visitCompletionRate;
  @override
  final int? programDurationSeconds;
  @override
  final double? avgDeviationSeconds;
  @override
  final double? manualVisitRatio;
  @override
  final int? ruleOverrideCount;
  @override
  final int? trackOperationCount;
  @override
  final int? exceptionApprovalCount;
  @override
  final BuiltList<CampSummaryStatsBottleneckRankingInner>? bottleneckRanking;

  factory _$CampSummaryStats([
    void Function(CampSummaryStatsBuilder)? updates,
  ]) => (CampSummaryStatsBuilder()..update(updates))._build();

  _$CampSummaryStats._({
    this.totalGroups,
    this.finishedGroupCount,
    this.completionRate,
    this.totalVisits,
    this.visitCompletionRate,
    this.programDurationSeconds,
    this.avgDeviationSeconds,
    this.manualVisitRatio,
    this.ruleOverrideCount,
    this.trackOperationCount,
    this.exceptionApprovalCount,
    this.bottleneckRanking,
  }) : super._();
  @override
  CampSummaryStats rebuild(void Function(CampSummaryStatsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CampSummaryStatsBuilder toBuilder() =>
      CampSummaryStatsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CampSummaryStats &&
        totalGroups == other.totalGroups &&
        finishedGroupCount == other.finishedGroupCount &&
        completionRate == other.completionRate &&
        totalVisits == other.totalVisits &&
        visitCompletionRate == other.visitCompletionRate &&
        programDurationSeconds == other.programDurationSeconds &&
        avgDeviationSeconds == other.avgDeviationSeconds &&
        manualVisitRatio == other.manualVisitRatio &&
        ruleOverrideCount == other.ruleOverrideCount &&
        trackOperationCount == other.trackOperationCount &&
        exceptionApprovalCount == other.exceptionApprovalCount &&
        bottleneckRanking == other.bottleneckRanking;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, totalGroups.hashCode);
    _$hash = $jc(_$hash, finishedGroupCount.hashCode);
    _$hash = $jc(_$hash, completionRate.hashCode);
    _$hash = $jc(_$hash, totalVisits.hashCode);
    _$hash = $jc(_$hash, visitCompletionRate.hashCode);
    _$hash = $jc(_$hash, programDurationSeconds.hashCode);
    _$hash = $jc(_$hash, avgDeviationSeconds.hashCode);
    _$hash = $jc(_$hash, manualVisitRatio.hashCode);
    _$hash = $jc(_$hash, ruleOverrideCount.hashCode);
    _$hash = $jc(_$hash, trackOperationCount.hashCode);
    _$hash = $jc(_$hash, exceptionApprovalCount.hashCode);
    _$hash = $jc(_$hash, bottleneckRanking.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CampSummaryStats')
          ..add('totalGroups', totalGroups)
          ..add('finishedGroupCount', finishedGroupCount)
          ..add('completionRate', completionRate)
          ..add('totalVisits', totalVisits)
          ..add('visitCompletionRate', visitCompletionRate)
          ..add('programDurationSeconds', programDurationSeconds)
          ..add('avgDeviationSeconds', avgDeviationSeconds)
          ..add('manualVisitRatio', manualVisitRatio)
          ..add('ruleOverrideCount', ruleOverrideCount)
          ..add('trackOperationCount', trackOperationCount)
          ..add('exceptionApprovalCount', exceptionApprovalCount)
          ..add('bottleneckRanking', bottleneckRanking))
        .toString();
  }
}

class CampSummaryStatsBuilder
    implements Builder<CampSummaryStats, CampSummaryStatsBuilder> {
  _$CampSummaryStats? _$v;

  int? _totalGroups;
  int? get totalGroups => _$this._totalGroups;
  set totalGroups(int? totalGroups) => _$this._totalGroups = totalGroups;

  int? _finishedGroupCount;
  int? get finishedGroupCount => _$this._finishedGroupCount;
  set finishedGroupCount(int? finishedGroupCount) =>
      _$this._finishedGroupCount = finishedGroupCount;

  double? _completionRate;
  double? get completionRate => _$this._completionRate;
  set completionRate(double? completionRate) =>
      _$this._completionRate = completionRate;

  int? _totalVisits;
  int? get totalVisits => _$this._totalVisits;
  set totalVisits(int? totalVisits) => _$this._totalVisits = totalVisits;

  double? _visitCompletionRate;
  double? get visitCompletionRate => _$this._visitCompletionRate;
  set visitCompletionRate(double? visitCompletionRate) =>
      _$this._visitCompletionRate = visitCompletionRate;

  int? _programDurationSeconds;
  int? get programDurationSeconds => _$this._programDurationSeconds;
  set programDurationSeconds(int? programDurationSeconds) =>
      _$this._programDurationSeconds = programDurationSeconds;

  double? _avgDeviationSeconds;
  double? get avgDeviationSeconds => _$this._avgDeviationSeconds;
  set avgDeviationSeconds(double? avgDeviationSeconds) =>
      _$this._avgDeviationSeconds = avgDeviationSeconds;

  double? _manualVisitRatio;
  double? get manualVisitRatio => _$this._manualVisitRatio;
  set manualVisitRatio(double? manualVisitRatio) =>
      _$this._manualVisitRatio = manualVisitRatio;

  int? _ruleOverrideCount;
  int? get ruleOverrideCount => _$this._ruleOverrideCount;
  set ruleOverrideCount(int? ruleOverrideCount) =>
      _$this._ruleOverrideCount = ruleOverrideCount;

  int? _trackOperationCount;
  int? get trackOperationCount => _$this._trackOperationCount;
  set trackOperationCount(int? trackOperationCount) =>
      _$this._trackOperationCount = trackOperationCount;

  int? _exceptionApprovalCount;
  int? get exceptionApprovalCount => _$this._exceptionApprovalCount;
  set exceptionApprovalCount(int? exceptionApprovalCount) =>
      _$this._exceptionApprovalCount = exceptionApprovalCount;

  ListBuilder<CampSummaryStatsBottleneckRankingInner>? _bottleneckRanking;
  ListBuilder<CampSummaryStatsBottleneckRankingInner> get bottleneckRanking =>
      _$this._bottleneckRanking ??=
          ListBuilder<CampSummaryStatsBottleneckRankingInner>();
  set bottleneckRanking(
    ListBuilder<CampSummaryStatsBottleneckRankingInner>? bottleneckRanking,
  ) => _$this._bottleneckRanking = bottleneckRanking;

  CampSummaryStatsBuilder() {
    CampSummaryStats._defaults(this);
  }

  CampSummaryStatsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _totalGroups = $v.totalGroups;
      _finishedGroupCount = $v.finishedGroupCount;
      _completionRate = $v.completionRate;
      _totalVisits = $v.totalVisits;
      _visitCompletionRate = $v.visitCompletionRate;
      _programDurationSeconds = $v.programDurationSeconds;
      _avgDeviationSeconds = $v.avgDeviationSeconds;
      _manualVisitRatio = $v.manualVisitRatio;
      _ruleOverrideCount = $v.ruleOverrideCount;
      _trackOperationCount = $v.trackOperationCount;
      _exceptionApprovalCount = $v.exceptionApprovalCount;
      _bottleneckRanking = $v.bottleneckRanking?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CampSummaryStats other) {
    _$v = other as _$CampSummaryStats;
  }

  @override
  void update(void Function(CampSummaryStatsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CampSummaryStats build() => _build();

  _$CampSummaryStats _build() {
    _$CampSummaryStats _$result;
    try {
      _$result =
          _$v ??
          _$CampSummaryStats._(
            totalGroups: totalGroups,
            finishedGroupCount: finishedGroupCount,
            completionRate: completionRate,
            totalVisits: totalVisits,
            visitCompletionRate: visitCompletionRate,
            programDurationSeconds: programDurationSeconds,
            avgDeviationSeconds: avgDeviationSeconds,
            manualVisitRatio: manualVisitRatio,
            ruleOverrideCount: ruleOverrideCount,
            trackOperationCount: trackOperationCount,
            exceptionApprovalCount: exceptionApprovalCount,
            bottleneckRanking: _bottleneckRanking?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'bottleneckRanking';
        _bottleneckRanking?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'CampSummaryStats',
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
