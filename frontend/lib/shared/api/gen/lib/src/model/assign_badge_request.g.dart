// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'assign_badge_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AssignBadgeRequest extends AssignBadgeRequest {
  @override
  final String? groupId;

  factory _$AssignBadgeRequest(
          [void Function(AssignBadgeRequestBuilder)? updates]) =>
      (AssignBadgeRequestBuilder()..update(updates))._build();

  _$AssignBadgeRequest._({this.groupId}) : super._();
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
    return other is AssignBadgeRequest && groupId == other.groupId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, groupId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AssignBadgeRequest')
          ..add('groupId', groupId))
        .toString();
  }
}

class AssignBadgeRequestBuilder
    implements Builder<AssignBadgeRequest, AssignBadgeRequestBuilder> {
  _$AssignBadgeRequest? _$v;

  String? _groupId;
  String? get groupId => _$this._groupId;
  set groupId(String? groupId) => _$this._groupId = groupId;

  AssignBadgeRequestBuilder() {
    AssignBadgeRequest._defaults(this);
  }

  AssignBadgeRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _groupId = $v.groupId;
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
          groupId: groupId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
