// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_stats_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TimelineStatsResponse extends TimelineStatsResponse {
  @override
  final BuiltList<TimelineBucketResponse>? buckets;

  factory _$TimelineStatsResponse(
          [void Function(TimelineStatsResponseBuilder)? updates]) =>
      (TimelineStatsResponseBuilder()..update(updates))._build();

  _$TimelineStatsResponse._({this.buckets}) : super._();
  @override
  TimelineStatsResponse rebuild(
          void Function(TimelineStatsResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TimelineStatsResponseBuilder toBuilder() =>
      TimelineStatsResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TimelineStatsResponse && buckets == other.buckets;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, buckets.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TimelineStatsResponse')
          ..add('buckets', buckets))
        .toString();
  }
}

class TimelineStatsResponseBuilder
    implements Builder<TimelineStatsResponse, TimelineStatsResponseBuilder> {
  _$TimelineStatsResponse? _$v;

  ListBuilder<TimelineBucketResponse>? _buckets;
  ListBuilder<TimelineBucketResponse> get buckets =>
      _$this._buckets ??= ListBuilder<TimelineBucketResponse>();
  set buckets(ListBuilder<TimelineBucketResponse>? buckets) =>
      _$this._buckets = buckets;

  TimelineStatsResponseBuilder() {
    TimelineStatsResponse._defaults(this);
  }

  TimelineStatsResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _buckets = $v.buckets?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TimelineStatsResponse other) {
    _$v = other as _$TimelineStatsResponse;
  }

  @override
  void update(void Function(TimelineStatsResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TimelineStatsResponse build() => _build();

  _$TimelineStatsResponse _build() {
    _$TimelineStatsResponse _$result;
    try {
      _$result = _$v ??
          _$TimelineStatsResponse._(
            buckets: _buckets?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'buckets';
        _buckets?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TimelineStatsResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
