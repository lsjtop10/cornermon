// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'bottleneck_ranking_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BottleneckRankingResponse extends BottleneckRankingResponse {
  @override
  final num? avgDeviationSeconds;
  @override
  final String? cornerId;
  @override
  final String? cornerName;

  factory _$BottleneckRankingResponse(
          [void Function(BottleneckRankingResponseBuilder)? updates]) =>
      (BottleneckRankingResponseBuilder()..update(updates))._build();

  _$BottleneckRankingResponse._(
      {this.avgDeviationSeconds, this.cornerId, this.cornerName})
      : super._();
  @override
  BottleneckRankingResponse rebuild(
          void Function(BottleneckRankingResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BottleneckRankingResponseBuilder toBuilder() =>
      BottleneckRankingResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BottleneckRankingResponse &&
        avgDeviationSeconds == other.avgDeviationSeconds &&
        cornerId == other.cornerId &&
        cornerName == other.cornerName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, avgDeviationSeconds.hashCode);
    _$hash = $jc(_$hash, cornerId.hashCode);
    _$hash = $jc(_$hash, cornerName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BottleneckRankingResponse')
          ..add('avgDeviationSeconds', avgDeviationSeconds)
          ..add('cornerId', cornerId)
          ..add('cornerName', cornerName))
        .toString();
  }
}

class BottleneckRankingResponseBuilder
    implements
        Builder<BottleneckRankingResponse, BottleneckRankingResponseBuilder> {
  _$BottleneckRankingResponse? _$v;

  num? _avgDeviationSeconds;
  num? get avgDeviationSeconds => _$this._avgDeviationSeconds;
  set avgDeviationSeconds(num? avgDeviationSeconds) =>
      _$this._avgDeviationSeconds = avgDeviationSeconds;

  String? _cornerId;
  String? get cornerId => _$this._cornerId;
  set cornerId(String? cornerId) => _$this._cornerId = cornerId;

  String? _cornerName;
  String? get cornerName => _$this._cornerName;
  set cornerName(String? cornerName) => _$this._cornerName = cornerName;

  BottleneckRankingResponseBuilder() {
    BottleneckRankingResponse._defaults(this);
  }

  BottleneckRankingResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _avgDeviationSeconds = $v.avgDeviationSeconds;
      _cornerId = $v.cornerId;
      _cornerName = $v.cornerName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BottleneckRankingResponse other) {
    _$v = other as _$BottleneckRankingResponse;
  }

  @override
  void update(void Function(BottleneckRankingResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BottleneckRankingResponse build() => _build();

  _$BottleneckRankingResponse _build() {
    final _$result = _$v ??
        _$BottleneckRankingResponse._(
          avgDeviationSeconds: avgDeviationSeconds,
          cornerId: cornerId,
          cornerName: cornerName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
