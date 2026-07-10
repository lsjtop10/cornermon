// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_stats.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TimelineStats extends TimelineStats {
  @override
  final int? bucketMinutes;
  @override
  final BuiltList<TimelineStatsInProgressCountsInner>? inProgressCounts;
  @override
  final BuiltList<TimelineStatsInProgressCountsInner>?
  cumulativeCompletedCounts;

  factory _$TimelineStats([void Function(TimelineStatsBuilder)? updates]) =>
      (TimelineStatsBuilder()..update(updates))._build();

  _$TimelineStats._({
    this.bucketMinutes,
    this.inProgressCounts,
    this.cumulativeCompletedCounts,
  }) : super._();
  @override
  TimelineStats rebuild(void Function(TimelineStatsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TimelineStatsBuilder toBuilder() => TimelineStatsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TimelineStats &&
        bucketMinutes == other.bucketMinutes &&
        inProgressCounts == other.inProgressCounts &&
        cumulativeCompletedCounts == other.cumulativeCompletedCounts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, bucketMinutes.hashCode);
    _$hash = $jc(_$hash, inProgressCounts.hashCode);
    _$hash = $jc(_$hash, cumulativeCompletedCounts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TimelineStats')
          ..add('bucketMinutes', bucketMinutes)
          ..add('inProgressCounts', inProgressCounts)
          ..add('cumulativeCompletedCounts', cumulativeCompletedCounts))
        .toString();
  }
}

class TimelineStatsBuilder
    implements Builder<TimelineStats, TimelineStatsBuilder> {
  _$TimelineStats? _$v;

  int? _bucketMinutes;
  int? get bucketMinutes => _$this._bucketMinutes;
  set bucketMinutes(int? bucketMinutes) =>
      _$this._bucketMinutes = bucketMinutes;

  ListBuilder<TimelineStatsInProgressCountsInner>? _inProgressCounts;
  ListBuilder<TimelineStatsInProgressCountsInner> get inProgressCounts =>
      _$this._inProgressCounts ??=
          ListBuilder<TimelineStatsInProgressCountsInner>();
  set inProgressCounts(
    ListBuilder<TimelineStatsInProgressCountsInner>? inProgressCounts,
  ) => _$this._inProgressCounts = inProgressCounts;

  ListBuilder<TimelineStatsInProgressCountsInner>? _cumulativeCompletedCounts;
  ListBuilder<TimelineStatsInProgressCountsInner>
  get cumulativeCompletedCounts => _$this._cumulativeCompletedCounts ??=
      ListBuilder<TimelineStatsInProgressCountsInner>();
  set cumulativeCompletedCounts(
    ListBuilder<TimelineStatsInProgressCountsInner>? cumulativeCompletedCounts,
  ) => _$this._cumulativeCompletedCounts = cumulativeCompletedCounts;

  TimelineStatsBuilder() {
    TimelineStats._defaults(this);
  }

  TimelineStatsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bucketMinutes = $v.bucketMinutes;
      _inProgressCounts = $v.inProgressCounts?.toBuilder();
      _cumulativeCompletedCounts = $v.cumulativeCompletedCounts?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TimelineStats other) {
    _$v = other as _$TimelineStats;
  }

  @override
  void update(void Function(TimelineStatsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TimelineStats build() => _build();

  _$TimelineStats _build() {
    _$TimelineStats _$result;
    try {
      _$result =
          _$v ??
          _$TimelineStats._(
            bucketMinutes: bucketMinutes,
            inProgressCounts: _inProgressCounts?.build(),
            cumulativeCompletedCounts: _cumulativeCompletedCounts?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'inProgressCounts';
        _inProgressCounts?.build();
        _$failedField = 'cumulativeCompletedCounts';
        _cumulativeCompletedCounts?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'TimelineStats',
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
