// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corner_stats_unvisited_groups_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CornerStatsUnvisitedGroupsInner
    extends CornerStatsUnvisitedGroupsInner {
  @override
  final String? groupId;
  @override
  final String? groupName;

  factory _$CornerStatsUnvisitedGroupsInner(
          [void Function(CornerStatsUnvisitedGroupsInnerBuilder)? updates]) =>
      (CornerStatsUnvisitedGroupsInnerBuilder()..update(updates))._build();

  _$CornerStatsUnvisitedGroupsInner._({this.groupId, this.groupName})
      : super._();
  @override
  CornerStatsUnvisitedGroupsInner rebuild(
          void Function(CornerStatsUnvisitedGroupsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CornerStatsUnvisitedGroupsInnerBuilder toBuilder() =>
      CornerStatsUnvisitedGroupsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CornerStatsUnvisitedGroupsInner &&
        groupId == other.groupId &&
        groupName == other.groupName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, groupId.hashCode);
    _$hash = $jc(_$hash, groupName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CornerStatsUnvisitedGroupsInner')
          ..add('groupId', groupId)
          ..add('groupName', groupName))
        .toString();
  }
}

class CornerStatsUnvisitedGroupsInnerBuilder
    implements
        Builder<CornerStatsUnvisitedGroupsInner,
            CornerStatsUnvisitedGroupsInnerBuilder> {
  _$CornerStatsUnvisitedGroupsInner? _$v;

  String? _groupId;
  String? get groupId => _$this._groupId;
  set groupId(String? groupId) => _$this._groupId = groupId;

  String? _groupName;
  String? get groupName => _$this._groupName;
  set groupName(String? groupName) => _$this._groupName = groupName;

  CornerStatsUnvisitedGroupsInnerBuilder() {
    CornerStatsUnvisitedGroupsInner._defaults(this);
  }

  CornerStatsUnvisitedGroupsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _groupId = $v.groupId;
      _groupName = $v.groupName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CornerStatsUnvisitedGroupsInner other) {
    _$v = other as _$CornerStatsUnvisitedGroupsInner;
  }

  @override
  void update(void Function(CornerStatsUnvisitedGroupsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CornerStatsUnvisitedGroupsInner build() => _build();

  _$CornerStatsUnvisitedGroupsInner _build() {
    final _$result = _$v ??
        _$CornerStatsUnvisitedGroupsInner._(
          groupId: groupId,
          groupName: groupName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
