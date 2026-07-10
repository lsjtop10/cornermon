// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_stats_in_progress_counts_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TimelineStatsInProgressCountsInner
    extends TimelineStatsInProgressCountsInner {
  @override
  final DateTime? bucketStart;
  @override
  final int? count;

  factory _$TimelineStatsInProgressCountsInner([
    void Function(TimelineStatsInProgressCountsInnerBuilder)? updates,
  ]) => (TimelineStatsInProgressCountsInnerBuilder()..update(updates))._build();

  _$TimelineStatsInProgressCountsInner._({this.bucketStart, this.count})
    : super._();
  @override
  TimelineStatsInProgressCountsInner rebuild(
    void Function(TimelineStatsInProgressCountsInnerBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  TimelineStatsInProgressCountsInnerBuilder toBuilder() =>
      TimelineStatsInProgressCountsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TimelineStatsInProgressCountsInner &&
        bucketStart == other.bucketStart &&
        count == other.count;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, bucketStart.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TimelineStatsInProgressCountsInner')
          ..add('bucketStart', bucketStart)
          ..add('count', count))
        .toString();
  }
}

class TimelineStatsInProgressCountsInnerBuilder
    implements
        Builder<
          TimelineStatsInProgressCountsInner,
          TimelineStatsInProgressCountsInnerBuilder
        > {
  _$TimelineStatsInProgressCountsInner? _$v;

  DateTime? _bucketStart;
  DateTime? get bucketStart => _$this._bucketStart;
  set bucketStart(DateTime? bucketStart) => _$this._bucketStart = bucketStart;

  int? _count;
  int? get count => _$this._count;
  set count(int? count) => _$this._count = count;

  TimelineStatsInProgressCountsInnerBuilder() {
    TimelineStatsInProgressCountsInner._defaults(this);
  }

  TimelineStatsInProgressCountsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bucketStart = $v.bucketStart;
      _count = $v.count;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TimelineStatsInProgressCountsInner other) {
    _$v = other as _$TimelineStatsInProgressCountsInner;
  }

  @override
  void update(
    void Function(TimelineStatsInProgressCountsInnerBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  TimelineStatsInProgressCountsInner build() => _build();

  _$TimelineStatsInProgressCountsInner _build() {
    final _$result =
        _$v ??
        _$TimelineStatsInProgressCountsInner._(
          bucketStart: bucketStart,
          count: count,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
