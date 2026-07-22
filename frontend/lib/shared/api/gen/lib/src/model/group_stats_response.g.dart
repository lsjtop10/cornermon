// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'group_stats_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GroupStatsResponse extends GroupStatsResponse {
  @override
  final int? completedCount;
  @override
  final String? groupId;
  @override
  final String? groupName;
  @override
  final int? totalDurationSeconds;

  factory _$GroupStatsResponse(
          [void Function(GroupStatsResponseBuilder)? updates]) =>
      (GroupStatsResponseBuilder()..update(updates))._build();

  _$GroupStatsResponse._(
      {this.completedCount,
      this.groupId,
      this.groupName,
      this.totalDurationSeconds})
      : super._();
  @override
  GroupStatsResponse rebuild(
          void Function(GroupStatsResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GroupStatsResponseBuilder toBuilder() =>
      GroupStatsResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GroupStatsResponse &&
        completedCount == other.completedCount &&
        groupId == other.groupId &&
        groupName == other.groupName &&
        totalDurationSeconds == other.totalDurationSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, completedCount.hashCode);
    _$hash = $jc(_$hash, groupId.hashCode);
    _$hash = $jc(_$hash, groupName.hashCode);
    _$hash = $jc(_$hash, totalDurationSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GroupStatsResponse')
          ..add('completedCount', completedCount)
          ..add('groupId', groupId)
          ..add('groupName', groupName)
          ..add('totalDurationSeconds', totalDurationSeconds))
        .toString();
  }
}

class GroupStatsResponseBuilder
    implements Builder<GroupStatsResponse, GroupStatsResponseBuilder> {
  _$GroupStatsResponse? _$v;

  int? _completedCount;
  int? get completedCount => _$this._completedCount;
  set completedCount(int? completedCount) =>
      _$this._completedCount = completedCount;

  String? _groupId;
  String? get groupId => _$this._groupId;
  set groupId(String? groupId) => _$this._groupId = groupId;

  String? _groupName;
  String? get groupName => _$this._groupName;
  set groupName(String? groupName) => _$this._groupName = groupName;

  int? _totalDurationSeconds;
  int? get totalDurationSeconds => _$this._totalDurationSeconds;
  set totalDurationSeconds(int? totalDurationSeconds) =>
      _$this._totalDurationSeconds = totalDurationSeconds;

  GroupStatsResponseBuilder() {
    GroupStatsResponse._defaults(this);
  }

  GroupStatsResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _completedCount = $v.completedCount;
      _groupId = $v.groupId;
      _groupName = $v.groupName;
      _totalDurationSeconds = $v.totalDurationSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GroupStatsResponse other) {
    _$v = other as _$GroupStatsResponse;
  }

  @override
  void update(void Function(GroupStatsResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GroupStatsResponse build() => _build();

  _$GroupStatsResponse _build() {
    final _$result = _$v ??
        _$GroupStatsResponse._(
          completedCount: completedCount,
          groupId: groupId,
          groupName: groupName,
          totalDurationSeconds: totalDurationSeconds,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
