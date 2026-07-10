// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groups_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GroupsGet200Response extends GroupsGet200Response {
  @override
  final BuiltList<Group>? groups;

  factory _$GroupsGet200Response(
          [void Function(GroupsGet200ResponseBuilder)? updates]) =>
      (GroupsGet200ResponseBuilder()..update(updates))._build();

  _$GroupsGet200Response._({this.groups}) : super._();
  @override
  GroupsGet200Response rebuild(
          void Function(GroupsGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GroupsGet200ResponseBuilder toBuilder() =>
      GroupsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GroupsGet200Response && groups == other.groups;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, groups.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GroupsGet200Response')
          ..add('groups', groups))
        .toString();
  }
}

class GroupsGet200ResponseBuilder
    implements Builder<GroupsGet200Response, GroupsGet200ResponseBuilder> {
  _$GroupsGet200Response? _$v;

  ListBuilder<Group>? _groups;
  ListBuilder<Group> get groups => _$this._groups ??= ListBuilder<Group>();
  set groups(ListBuilder<Group>? groups) => _$this._groups = groups;

  GroupsGet200ResponseBuilder() {
    GroupsGet200Response._defaults(this);
  }

  GroupsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _groups = $v.groups?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GroupsGet200Response other) {
    _$v = other as _$GroupsGet200Response;
  }

  @override
  void update(void Function(GroupsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GroupsGet200Response build() => _build();

  _$GroupsGet200Response _build() {
    _$GroupsGet200Response _$result;
    try {
      _$result = _$v ??
          _$GroupsGet200Response._(
            groups: _groups?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'groups';
        _groups?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GroupsGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
