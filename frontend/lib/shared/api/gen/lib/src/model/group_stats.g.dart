// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_stats.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GroupStats extends GroupStats {
  @override
  final String? groupId;
  @override
  final String? groupName;
  @override
  final bool? isFinished;
  @override
  final int? completedCornerCount;
  @override
  final int? totalActivitySeconds;
  @override
  final BuiltList<GroupStatsCornerDurationsInner>? cornerDurations;
  @override
  final BuiltList<GroupStatsUnvisitedCornersInner>? unvisitedCorners;

  factory _$GroupStats([void Function(GroupStatsBuilder)? updates]) =>
      (GroupStatsBuilder()..update(updates))._build();

  _$GroupStats._(
      {this.groupId,
      this.groupName,
      this.isFinished,
      this.completedCornerCount,
      this.totalActivitySeconds,
      this.cornerDurations,
      this.unvisitedCorners})
      : super._();
  @override
  GroupStats rebuild(void Function(GroupStatsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GroupStatsBuilder toBuilder() => GroupStatsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GroupStats &&
        groupId == other.groupId &&
        groupName == other.groupName &&
        isFinished == other.isFinished &&
        completedCornerCount == other.completedCornerCount &&
        totalActivitySeconds == other.totalActivitySeconds &&
        cornerDurations == other.cornerDurations &&
        unvisitedCorners == other.unvisitedCorners;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, groupId.hashCode);
    _$hash = $jc(_$hash, groupName.hashCode);
    _$hash = $jc(_$hash, isFinished.hashCode);
    _$hash = $jc(_$hash, completedCornerCount.hashCode);
    _$hash = $jc(_$hash, totalActivitySeconds.hashCode);
    _$hash = $jc(_$hash, cornerDurations.hashCode);
    _$hash = $jc(_$hash, unvisitedCorners.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GroupStats')
          ..add('groupId', groupId)
          ..add('groupName', groupName)
          ..add('isFinished', isFinished)
          ..add('completedCornerCount', completedCornerCount)
          ..add('totalActivitySeconds', totalActivitySeconds)
          ..add('cornerDurations', cornerDurations)
          ..add('unvisitedCorners', unvisitedCorners))
        .toString();
  }
}

class GroupStatsBuilder implements Builder<GroupStats, GroupStatsBuilder> {
  _$GroupStats? _$v;

  String? _groupId;
  String? get groupId => _$this._groupId;
  set groupId(String? groupId) => _$this._groupId = groupId;

  String? _groupName;
  String? get groupName => _$this._groupName;
  set groupName(String? groupName) => _$this._groupName = groupName;

  bool? _isFinished;
  bool? get isFinished => _$this._isFinished;
  set isFinished(bool? isFinished) => _$this._isFinished = isFinished;

  int? _completedCornerCount;
  int? get completedCornerCount => _$this._completedCornerCount;
  set completedCornerCount(int? completedCornerCount) =>
      _$this._completedCornerCount = completedCornerCount;

  int? _totalActivitySeconds;
  int? get totalActivitySeconds => _$this._totalActivitySeconds;
  set totalActivitySeconds(int? totalActivitySeconds) =>
      _$this._totalActivitySeconds = totalActivitySeconds;

  ListBuilder<GroupStatsCornerDurationsInner>? _cornerDurations;
  ListBuilder<GroupStatsCornerDurationsInner> get cornerDurations =>
      _$this._cornerDurations ??= ListBuilder<GroupStatsCornerDurationsInner>();
  set cornerDurations(
          ListBuilder<GroupStatsCornerDurationsInner>? cornerDurations) =>
      _$this._cornerDurations = cornerDurations;

  ListBuilder<GroupStatsUnvisitedCornersInner>? _unvisitedCorners;
  ListBuilder<GroupStatsUnvisitedCornersInner> get unvisitedCorners =>
      _$this._unvisitedCorners ??=
          ListBuilder<GroupStatsUnvisitedCornersInner>();
  set unvisitedCorners(
          ListBuilder<GroupStatsUnvisitedCornersInner>? unvisitedCorners) =>
      _$this._unvisitedCorners = unvisitedCorners;

  GroupStatsBuilder() {
    GroupStats._defaults(this);
  }

  GroupStatsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _groupId = $v.groupId;
      _groupName = $v.groupName;
      _isFinished = $v.isFinished;
      _completedCornerCount = $v.completedCornerCount;
      _totalActivitySeconds = $v.totalActivitySeconds;
      _cornerDurations = $v.cornerDurations?.toBuilder();
      _unvisitedCorners = $v.unvisitedCorners?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GroupStats other) {
    _$v = other as _$GroupStats;
  }

  @override
  void update(void Function(GroupStatsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GroupStats build() => _build();

  _$GroupStats _build() {
    _$GroupStats _$result;
    try {
      _$result = _$v ??
          _$GroupStats._(
            groupId: groupId,
            groupName: groupName,
            isFinished: isFinished,
            completedCornerCount: completedCornerCount,
            totalActivitySeconds: totalActivitySeconds,
            cornerDurations: _cornerDurations?.build(),
            unvisitedCorners: _unvisitedCorners?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'cornerDurations';
        _cornerDurations?.build();
        _$failedField = 'unvisitedCorners';
        _unvisitedCorners?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GroupStats', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
