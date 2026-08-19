// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_bucket_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TimelineBucketResponse extends TimelineBucketResponse {
  @override
  final DateTime? bucketStart;
  @override
  final int? cumulativeCompleted;
  @override
  final int? inProgressCount;

  factory _$TimelineBucketResponse(
          [void Function(TimelineBucketResponseBuilder)? updates]) =>
      (TimelineBucketResponseBuilder()..update(updates))._build();

  _$TimelineBucketResponse._(
      {this.bucketStart, this.cumulativeCompleted, this.inProgressCount})
      : super._();
  @override
  TimelineBucketResponse rebuild(
          void Function(TimelineBucketResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TimelineBucketResponseBuilder toBuilder() =>
      TimelineBucketResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TimelineBucketResponse &&
        bucketStart == other.bucketStart &&
        cumulativeCompleted == other.cumulativeCompleted &&
        inProgressCount == other.inProgressCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, bucketStart.hashCode);
    _$hash = $jc(_$hash, cumulativeCompleted.hashCode);
    _$hash = $jc(_$hash, inProgressCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TimelineBucketResponse')
          ..add('bucketStart', bucketStart)
          ..add('cumulativeCompleted', cumulativeCompleted)
          ..add('inProgressCount', inProgressCount))
        .toString();
  }
}

class TimelineBucketResponseBuilder
    implements Builder<TimelineBucketResponse, TimelineBucketResponseBuilder> {
  _$TimelineBucketResponse? _$v;

  DateTime? _bucketStart;
  DateTime? get bucketStart => _$this._bucketStart;
  set bucketStart(DateTime? bucketStart) => _$this._bucketStart = bucketStart;

  int? _cumulativeCompleted;
  int? get cumulativeCompleted => _$this._cumulativeCompleted;
  set cumulativeCompleted(int? cumulativeCompleted) =>
      _$this._cumulativeCompleted = cumulativeCompleted;

  int? _inProgressCount;
  int? get inProgressCount => _$this._inProgressCount;
  set inProgressCount(int? inProgressCount) =>
      _$this._inProgressCount = inProgressCount;

  TimelineBucketResponseBuilder() {
    TimelineBucketResponse._defaults(this);
  }

  TimelineBucketResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bucketStart = $v.bucketStart;
      _cumulativeCompleted = $v.cumulativeCompleted;
      _inProgressCount = $v.inProgressCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TimelineBucketResponse other) {
    _$v = other as _$TimelineBucketResponse;
  }

  @override
  void update(void Function(TimelineBucketResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TimelineBucketResponse build() => _build();

  _$TimelineBucketResponse _build() {
    final _$result = _$v ??
        _$TimelineBucketResponse._(
          bucketStart: bucketStart,
          cumulativeCompleted: cumulativeCompleted,
          inProgressCount: inProgressCount,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
