// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_stats_unvisited_corners_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GroupStatsUnvisitedCornersInner
    extends GroupStatsUnvisitedCornersInner {
  @override
  final String? cornerId;
  @override
  final String? cornerName;

  factory _$GroupStatsUnvisitedCornersInner(
          [void Function(GroupStatsUnvisitedCornersInnerBuilder)? updates]) =>
      (GroupStatsUnvisitedCornersInnerBuilder()..update(updates))._build();

  _$GroupStatsUnvisitedCornersInner._({this.cornerId, this.cornerName})
      : super._();
  @override
  GroupStatsUnvisitedCornersInner rebuild(
          void Function(GroupStatsUnvisitedCornersInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GroupStatsUnvisitedCornersInnerBuilder toBuilder() =>
      GroupStatsUnvisitedCornersInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GroupStatsUnvisitedCornersInner &&
        cornerId == other.cornerId &&
        cornerName == other.cornerName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cornerId.hashCode);
    _$hash = $jc(_$hash, cornerName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GroupStatsUnvisitedCornersInner')
          ..add('cornerId', cornerId)
          ..add('cornerName', cornerName))
        .toString();
  }
}

class GroupStatsUnvisitedCornersInnerBuilder
    implements
        Builder<GroupStatsUnvisitedCornersInner,
            GroupStatsUnvisitedCornersInnerBuilder> {
  _$GroupStatsUnvisitedCornersInner? _$v;

  String? _cornerId;
  String? get cornerId => _$this._cornerId;
  set cornerId(String? cornerId) => _$this._cornerId = cornerId;

  String? _cornerName;
  String? get cornerName => _$this._cornerName;
  set cornerName(String? cornerName) => _$this._cornerName = cornerName;

  GroupStatsUnvisitedCornersInnerBuilder() {
    GroupStatsUnvisitedCornersInner._defaults(this);
  }

  GroupStatsUnvisitedCornersInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cornerId = $v.cornerId;
      _cornerName = $v.cornerName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GroupStatsUnvisitedCornersInner other) {
    _$v = other as _$GroupStatsUnvisitedCornersInner;
  }

  @override
  void update(void Function(GroupStatsUnvisitedCornersInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GroupStatsUnvisitedCornersInner build() => _build();

  _$GroupStatsUnvisitedCornersInner _build() {
    final _$result = _$v ??
        _$GroupStatsUnvisitedCornersInner._(
          cornerId: cornerId,
          cornerName: cornerName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
