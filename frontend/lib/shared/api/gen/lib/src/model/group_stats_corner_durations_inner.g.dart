// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_stats_corner_durations_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GroupStatsCornerDurationsInner extends GroupStatsCornerDurationsInner {
  @override
  final String? cornerId;
  @override
  final String? cornerName;
  @override
  final int? durationSeconds;

  factory _$GroupStatsCornerDurationsInner([
    void Function(GroupStatsCornerDurationsInnerBuilder)? updates,
  ]) => (GroupStatsCornerDurationsInnerBuilder()..update(updates))._build();

  _$GroupStatsCornerDurationsInner._({
    this.cornerId,
    this.cornerName,
    this.durationSeconds,
  }) : super._();
  @override
  GroupStatsCornerDurationsInner rebuild(
    void Function(GroupStatsCornerDurationsInnerBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GroupStatsCornerDurationsInnerBuilder toBuilder() =>
      GroupStatsCornerDurationsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GroupStatsCornerDurationsInner &&
        cornerId == other.cornerId &&
        cornerName == other.cornerName &&
        durationSeconds == other.durationSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cornerId.hashCode);
    _$hash = $jc(_$hash, cornerName.hashCode);
    _$hash = $jc(_$hash, durationSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GroupStatsCornerDurationsInner')
          ..add('cornerId', cornerId)
          ..add('cornerName', cornerName)
          ..add('durationSeconds', durationSeconds))
        .toString();
  }
}

class GroupStatsCornerDurationsInnerBuilder
    implements
        Builder<
          GroupStatsCornerDurationsInner,
          GroupStatsCornerDurationsInnerBuilder
        > {
  _$GroupStatsCornerDurationsInner? _$v;

  String? _cornerId;
  String? get cornerId => _$this._cornerId;
  set cornerId(String? cornerId) => _$this._cornerId = cornerId;

  String? _cornerName;
  String? get cornerName => _$this._cornerName;
  set cornerName(String? cornerName) => _$this._cornerName = cornerName;

  int? _durationSeconds;
  int? get durationSeconds => _$this._durationSeconds;
  set durationSeconds(int? durationSeconds) =>
      _$this._durationSeconds = durationSeconds;

  GroupStatsCornerDurationsInnerBuilder() {
    GroupStatsCornerDurationsInner._defaults(this);
  }

  GroupStatsCornerDurationsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cornerId = $v.cornerId;
      _cornerName = $v.cornerName;
      _durationSeconds = $v.durationSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GroupStatsCornerDurationsInner other) {
    _$v = other as _$GroupStatsCornerDurationsInner;
  }

  @override
  void update(void Function(GroupStatsCornerDurationsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GroupStatsCornerDurationsInner build() => _build();

  _$GroupStatsCornerDurationsInner _build() {
    final _$result =
        _$v ??
        _$GroupStatsCornerDurationsInner._(
          cornerId: cornerId,
          cornerName: cornerName,
          durationSeconds: durationSeconds,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
