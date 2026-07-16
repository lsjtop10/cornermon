// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corner_metric_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CornerMetricResponse extends CornerMetricResponse {
  @override
  final int? avgDurationSeconds;
  @override
  final int? sampleCount;

  factory _$CornerMetricResponse(
          [void Function(CornerMetricResponseBuilder)? updates]) =>
      (CornerMetricResponseBuilder()..update(updates))._build();

  _$CornerMetricResponse._({this.avgDurationSeconds, this.sampleCount})
      : super._();
  @override
  CornerMetricResponse rebuild(
          void Function(CornerMetricResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CornerMetricResponseBuilder toBuilder() =>
      CornerMetricResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CornerMetricResponse &&
        avgDurationSeconds == other.avgDurationSeconds &&
        sampleCount == other.sampleCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, avgDurationSeconds.hashCode);
    _$hash = $jc(_$hash, sampleCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CornerMetricResponse')
          ..add('avgDurationSeconds', avgDurationSeconds)
          ..add('sampleCount', sampleCount))
        .toString();
  }
}

class CornerMetricResponseBuilder
    implements Builder<CornerMetricResponse, CornerMetricResponseBuilder> {
  _$CornerMetricResponse? _$v;

  int? _avgDurationSeconds;
  int? get avgDurationSeconds => _$this._avgDurationSeconds;
  set avgDurationSeconds(int? avgDurationSeconds) =>
      _$this._avgDurationSeconds = avgDurationSeconds;

  int? _sampleCount;
  int? get sampleCount => _$this._sampleCount;
  set sampleCount(int? sampleCount) => _$this._sampleCount = sampleCount;

  CornerMetricResponseBuilder() {
    CornerMetricResponse._defaults(this);
  }

  CornerMetricResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _avgDurationSeconds = $v.avgDurationSeconds;
      _sampleCount = $v.sampleCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CornerMetricResponse other) {
    _$v = other as _$CornerMetricResponse;
  }

  @override
  void update(void Function(CornerMetricResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CornerMetricResponse build() => _build();

  _$CornerMetricResponse _build() {
    final _$result = _$v ??
        _$CornerMetricResponse._(
          avgDurationSeconds: avgDurationSeconds,
          sampleCount: sampleCount,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
