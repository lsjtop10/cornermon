// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'corner_stats_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CornerStatsResponse extends CornerStatsResponse {
  @override
  final num? avgDeviationSeconds;
  @override
  final num? avgDurationSeconds;
  @override
  final int? completedVisitCount;
  @override
  final String? cornerId;
  @override
  final String? cornerName;
  @override
  final num? overDeviationRatio;
  @override
  final BuiltList<UnvisitedGroupResponse>? unvisitedGroups;

  factory _$CornerStatsResponse(
          [void Function(CornerStatsResponseBuilder)? updates]) =>
      (CornerStatsResponseBuilder()..update(updates))._build();

  _$CornerStatsResponse._(
      {this.avgDeviationSeconds,
      this.avgDurationSeconds,
      this.completedVisitCount,
      this.cornerId,
      this.cornerName,
      this.overDeviationRatio,
      this.unvisitedGroups})
      : super._();
  @override
  CornerStatsResponse rebuild(
          void Function(CornerStatsResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CornerStatsResponseBuilder toBuilder() =>
      CornerStatsResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CornerStatsResponse &&
        avgDeviationSeconds == other.avgDeviationSeconds &&
        avgDurationSeconds == other.avgDurationSeconds &&
        completedVisitCount == other.completedVisitCount &&
        cornerId == other.cornerId &&
        cornerName == other.cornerName &&
        overDeviationRatio == other.overDeviationRatio &&
        unvisitedGroups == other.unvisitedGroups;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, avgDeviationSeconds.hashCode);
    _$hash = $jc(_$hash, avgDurationSeconds.hashCode);
    _$hash = $jc(_$hash, completedVisitCount.hashCode);
    _$hash = $jc(_$hash, cornerId.hashCode);
    _$hash = $jc(_$hash, cornerName.hashCode);
    _$hash = $jc(_$hash, overDeviationRatio.hashCode);
    _$hash = $jc(_$hash, unvisitedGroups.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CornerStatsResponse')
          ..add('avgDeviationSeconds', avgDeviationSeconds)
          ..add('avgDurationSeconds', avgDurationSeconds)
          ..add('completedVisitCount', completedVisitCount)
          ..add('cornerId', cornerId)
          ..add('cornerName', cornerName)
          ..add('overDeviationRatio', overDeviationRatio)
          ..add('unvisitedGroups', unvisitedGroups))
        .toString();
  }
}

class CornerStatsResponseBuilder
    implements Builder<CornerStatsResponse, CornerStatsResponseBuilder> {
  _$CornerStatsResponse? _$v;

  num? _avgDeviationSeconds;
  num? get avgDeviationSeconds => _$this._avgDeviationSeconds;
  set avgDeviationSeconds(num? avgDeviationSeconds) =>
      _$this._avgDeviationSeconds = avgDeviationSeconds;

  num? _avgDurationSeconds;
  num? get avgDurationSeconds => _$this._avgDurationSeconds;
  set avgDurationSeconds(num? avgDurationSeconds) =>
      _$this._avgDurationSeconds = avgDurationSeconds;

  int? _completedVisitCount;
  int? get completedVisitCount => _$this._completedVisitCount;
  set completedVisitCount(int? completedVisitCount) =>
      _$this._completedVisitCount = completedVisitCount;

  String? _cornerId;
  String? get cornerId => _$this._cornerId;
  set cornerId(String? cornerId) => _$this._cornerId = cornerId;

  String? _cornerName;
  String? get cornerName => _$this._cornerName;
  set cornerName(String? cornerName) => _$this._cornerName = cornerName;

  num? _overDeviationRatio;
  num? get overDeviationRatio => _$this._overDeviationRatio;
  set overDeviationRatio(num? overDeviationRatio) =>
      _$this._overDeviationRatio = overDeviationRatio;

  ListBuilder<UnvisitedGroupResponse>? _unvisitedGroups;
  ListBuilder<UnvisitedGroupResponse> get unvisitedGroups =>
      _$this._unvisitedGroups ??= ListBuilder<UnvisitedGroupResponse>();
  set unvisitedGroups(ListBuilder<UnvisitedGroupResponse>? unvisitedGroups) =>
      _$this._unvisitedGroups = unvisitedGroups;

  CornerStatsResponseBuilder() {
    CornerStatsResponse._defaults(this);
  }

  CornerStatsResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _avgDeviationSeconds = $v.avgDeviationSeconds;
      _avgDurationSeconds = $v.avgDurationSeconds;
      _completedVisitCount = $v.completedVisitCount;
      _cornerId = $v.cornerId;
      _cornerName = $v.cornerName;
      _overDeviationRatio = $v.overDeviationRatio;
      _unvisitedGroups = $v.unvisitedGroups?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CornerStatsResponse other) {
    _$v = other as _$CornerStatsResponse;
  }

  @override
  void update(void Function(CornerStatsResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CornerStatsResponse build() => _build();

  _$CornerStatsResponse _build() {
    _$CornerStatsResponse _$result;
    try {
      _$result = _$v ??
          _$CornerStatsResponse._(
            avgDeviationSeconds: avgDeviationSeconds,
            avgDurationSeconds: avgDurationSeconds,
            completedVisitCount: completedVisitCount,
            cornerId: cornerId,
            cornerName: cornerName,
            overDeviationRatio: overDeviationRatio,
            unvisitedGroups: _unvisitedGroups?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'unvisitedGroups';
        _unvisitedGroups?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CornerStatsResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
