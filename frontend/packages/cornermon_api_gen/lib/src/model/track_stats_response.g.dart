// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_stats_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackStatsResponse extends TrackStatsResponse {
  @override
  final int? avgDeviationSeconds;
  @override
  final int? handledVisitCount;
  @override
  final num? manualVisitRatio;
  @override
  final String? trackId;
  @override
  final int? trackNo;

  factory _$TrackStatsResponse(
          [void Function(TrackStatsResponseBuilder)? updates]) =>
      (TrackStatsResponseBuilder()..update(updates))._build();

  _$TrackStatsResponse._(
      {this.avgDeviationSeconds,
      this.handledVisitCount,
      this.manualVisitRatio,
      this.trackId,
      this.trackNo})
      : super._();
  @override
  TrackStatsResponse rebuild(
          void Function(TrackStatsResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackStatsResponseBuilder toBuilder() =>
      TrackStatsResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackStatsResponse &&
        avgDeviationSeconds == other.avgDeviationSeconds &&
        handledVisitCount == other.handledVisitCount &&
        manualVisitRatio == other.manualVisitRatio &&
        trackId == other.trackId &&
        trackNo == other.trackNo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, avgDeviationSeconds.hashCode);
    _$hash = $jc(_$hash, handledVisitCount.hashCode);
    _$hash = $jc(_$hash, manualVisitRatio.hashCode);
    _$hash = $jc(_$hash, trackId.hashCode);
    _$hash = $jc(_$hash, trackNo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackStatsResponse')
          ..add('avgDeviationSeconds', avgDeviationSeconds)
          ..add('handledVisitCount', handledVisitCount)
          ..add('manualVisitRatio', manualVisitRatio)
          ..add('trackId', trackId)
          ..add('trackNo', trackNo))
        .toString();
  }
}

class TrackStatsResponseBuilder
    implements Builder<TrackStatsResponse, TrackStatsResponseBuilder> {
  _$TrackStatsResponse? _$v;

  int? _avgDeviationSeconds;
  int? get avgDeviationSeconds => _$this._avgDeviationSeconds;
  set avgDeviationSeconds(int? avgDeviationSeconds) =>
      _$this._avgDeviationSeconds = avgDeviationSeconds;

  int? _handledVisitCount;
  int? get handledVisitCount => _$this._handledVisitCount;
  set handledVisitCount(int? handledVisitCount) =>
      _$this._handledVisitCount = handledVisitCount;

  num? _manualVisitRatio;
  num? get manualVisitRatio => _$this._manualVisitRatio;
  set manualVisitRatio(num? manualVisitRatio) =>
      _$this._manualVisitRatio = manualVisitRatio;

  String? _trackId;
  String? get trackId => _$this._trackId;
  set trackId(String? trackId) => _$this._trackId = trackId;

  int? _trackNo;
  int? get trackNo => _$this._trackNo;
  set trackNo(int? trackNo) => _$this._trackNo = trackNo;

  TrackStatsResponseBuilder() {
    TrackStatsResponse._defaults(this);
  }

  TrackStatsResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _avgDeviationSeconds = $v.avgDeviationSeconds;
      _handledVisitCount = $v.handledVisitCount;
      _manualVisitRatio = $v.manualVisitRatio;
      _trackId = $v.trackId;
      _trackNo = $v.trackNo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackStatsResponse other) {
    _$v = other as _$TrackStatsResponse;
  }

  @override
  void update(void Function(TrackStatsResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackStatsResponse build() => _build();

  _$TrackStatsResponse _build() {
    final _$result = _$v ??
        _$TrackStatsResponse._(
          avgDeviationSeconds: avgDeviationSeconds,
          handledVisitCount: handledVisitCount,
          manualVisitRatio: manualVisitRatio,
          trackId: trackId,
          trackNo: trackNo,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
