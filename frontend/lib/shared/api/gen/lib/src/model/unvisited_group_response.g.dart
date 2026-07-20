// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'unvisited_group_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UnvisitedGroupResponse extends UnvisitedGroupResponse {
  @override
  final String? groupId;
  @override
  final String? groupName;

  factory _$UnvisitedGroupResponse(
          [void Function(UnvisitedGroupResponseBuilder)? updates]) =>
      (UnvisitedGroupResponseBuilder()..update(updates))._build();

  _$UnvisitedGroupResponse._({this.groupId, this.groupName}) : super._();
  @override
  UnvisitedGroupResponse rebuild(
          void Function(UnvisitedGroupResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UnvisitedGroupResponseBuilder toBuilder() =>
      UnvisitedGroupResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UnvisitedGroupResponse &&
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
    return (newBuiltValueToStringHelper(r'UnvisitedGroupResponse')
          ..add('groupId', groupId)
          ..add('groupName', groupName))
        .toString();
  }
}

class UnvisitedGroupResponseBuilder
    implements Builder<UnvisitedGroupResponse, UnvisitedGroupResponseBuilder> {
  _$UnvisitedGroupResponse? _$v;

  String? _groupId;
  String? get groupId => _$this._groupId;
  set groupId(String? groupId) => _$this._groupId = groupId;

  String? _groupName;
  String? get groupName => _$this._groupName;
  set groupName(String? groupName) => _$this._groupName = groupName;

  UnvisitedGroupResponseBuilder() {
    UnvisitedGroupResponse._defaults(this);
  }

  UnvisitedGroupResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _groupId = $v.groupId;
      _groupName = $v.groupName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UnvisitedGroupResponse other) {
    _$v = other as _$UnvisitedGroupResponse;
  }

  @override
  void update(void Function(UnvisitedGroupResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UnvisitedGroupResponse build() => _build();

  _$UnvisitedGroupResponse _build() {
    final _$result = _$v ??
        _$UnvisitedGroupResponse._(
          groupId: groupId,
          groupName: groupName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
