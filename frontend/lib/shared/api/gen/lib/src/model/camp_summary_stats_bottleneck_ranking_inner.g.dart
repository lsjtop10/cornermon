// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camp_summary_stats_bottleneck_ranking_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CampSummaryStatsBottleneckRankingInner
    extends CampSummaryStatsBottleneckRankingInner {
  @override
  final String? cornerId;
  @override
  final String? cornerName;
  @override
  final num? avgDeviationSeconds;

  factory _$CampSummaryStatsBottleneckRankingInner([
    void Function(CampSummaryStatsBottleneckRankingInnerBuilder)? updates,
  ]) => (CampSummaryStatsBottleneckRankingInnerBuilder()..update(updates))
      ._build();

  _$CampSummaryStatsBottleneckRankingInner._({
    this.cornerId,
    this.cornerName,
    this.avgDeviationSeconds,
  }) : super._();
  @override
  CampSummaryStatsBottleneckRankingInner rebuild(
    void Function(CampSummaryStatsBottleneckRankingInnerBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CampSummaryStatsBottleneckRankingInnerBuilder toBuilder() =>
      CampSummaryStatsBottleneckRankingInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CampSummaryStatsBottleneckRankingInner &&
        cornerId == other.cornerId &&
        cornerName == other.cornerName &&
        avgDeviationSeconds == other.avgDeviationSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cornerId.hashCode);
    _$hash = $jc(_$hash, cornerName.hashCode);
    _$hash = $jc(_$hash, avgDeviationSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'CampSummaryStatsBottleneckRankingInner',
          )
          ..add('cornerId', cornerId)
          ..add('cornerName', cornerName)
          ..add('avgDeviationSeconds', avgDeviationSeconds))
        .toString();
  }
}

class CampSummaryStatsBottleneckRankingInnerBuilder
    implements
        Builder<
          CampSummaryStatsBottleneckRankingInner,
          CampSummaryStatsBottleneckRankingInnerBuilder
        > {
  _$CampSummaryStatsBottleneckRankingInner? _$v;

  String? _cornerId;
  String? get cornerId => _$this._cornerId;
  set cornerId(String? cornerId) => _$this._cornerId = cornerId;

  String? _cornerName;
  String? get cornerName => _$this._cornerName;
  set cornerName(String? cornerName) => _$this._cornerName = cornerName;

  num? _avgDeviationSeconds;
  num? get avgDeviationSeconds => _$this._avgDeviationSeconds;
  set avgDeviationSeconds(num? avgDeviationSeconds) =>
      _$this._avgDeviationSeconds = avgDeviationSeconds;

  CampSummaryStatsBottleneckRankingInnerBuilder() {
    CampSummaryStatsBottleneckRankingInner._defaults(this);
  }

  CampSummaryStatsBottleneckRankingInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cornerId = $v.cornerId;
      _cornerName = $v.cornerName;
      _avgDeviationSeconds = $v.avgDeviationSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CampSummaryStatsBottleneckRankingInner other) {
    _$v = other as _$CampSummaryStatsBottleneckRankingInner;
  }

  @override
  void update(
    void Function(CampSummaryStatsBottleneckRankingInnerBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  CampSummaryStatsBottleneckRankingInner build() => _build();

  _$CampSummaryStatsBottleneckRankingInner _build() {
    final _$result =
        _$v ??
        _$CampSummaryStatsBottleneckRankingInner._(
          cornerId: cornerId,
          cornerName: cornerName,
          avgDeviationSeconds: avgDeviationSeconds,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
