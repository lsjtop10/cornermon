// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'assign_badge_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AssignBadgeRequest extends AssignBadgeRequest {
  @override
  final String? campId;
  @override
  final String? groupName;

  factory _$AssignBadgeRequest(
          [void Function(AssignBadgeRequestBuilder)? updates]) =>
      (AssignBadgeRequestBuilder()..update(updates))._build();

  _$AssignBadgeRequest._({this.campId, this.groupName}) : super._();
  @override
  AssignBadgeRequest rebuild(
          void Function(AssignBadgeRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AssignBadgeRequestBuilder toBuilder() =>
      AssignBadgeRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AssignBadgeRequest &&
        campId == other.campId &&
        groupName == other.groupName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, campId.hashCode);
    _$hash = $jc(_$hash, groupName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AssignBadgeRequest')
          ..add('campId', campId)
          ..add('groupName', groupName))
        .toString();
  }
}

class AssignBadgeRequestBuilder
    implements Builder<AssignBadgeRequest, AssignBadgeRequestBuilder> {
  _$AssignBadgeRequest? _$v;

  String? _campId;
  String? get campId => _$this._campId;
  set campId(String? campId) => _$this._campId = campId;

  String? _groupName;
  String? get groupName => _$this._groupName;
  set groupName(String? groupName) => _$this._groupName = groupName;

  AssignBadgeRequestBuilder() {
    AssignBadgeRequest._defaults(this);
  }

  AssignBadgeRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _campId = $v.campId;
      _groupName = $v.groupName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AssignBadgeRequest other) {
    _$v = other as _$AssignBadgeRequest;
  }

  @override
  void update(void Function(AssignBadgeRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AssignBadgeRequest build() => _build();

  _$AssignBadgeRequest _build() {
    final _$result = _$v ??
        _$AssignBadgeRequest._(
          campId: campId,
          groupName: groupName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
