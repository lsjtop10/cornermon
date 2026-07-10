// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groups_id_visits_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GroupsIdVisitsGet200Response extends GroupsIdVisitsGet200Response {
  @override
  final BuiltList<VisitSummary>? visits;

  factory _$GroupsIdVisitsGet200Response([
    void Function(GroupsIdVisitsGet200ResponseBuilder)? updates,
  ]) => (GroupsIdVisitsGet200ResponseBuilder()..update(updates))._build();

  _$GroupsIdVisitsGet200Response._({this.visits}) : super._();
  @override
  GroupsIdVisitsGet200Response rebuild(
    void Function(GroupsIdVisitsGet200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GroupsIdVisitsGet200ResponseBuilder toBuilder() =>
      GroupsIdVisitsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GroupsIdVisitsGet200Response && visits == other.visits;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, visits.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'GroupsIdVisitsGet200Response',
    )..add('visits', visits)).toString();
  }
}

class GroupsIdVisitsGet200ResponseBuilder
    implements
        Builder<
          GroupsIdVisitsGet200Response,
          GroupsIdVisitsGet200ResponseBuilder
        > {
  _$GroupsIdVisitsGet200Response? _$v;

  ListBuilder<VisitSummary>? _visits;
  ListBuilder<VisitSummary> get visits =>
      _$this._visits ??= ListBuilder<VisitSummary>();
  set visits(ListBuilder<VisitSummary>? visits) => _$this._visits = visits;

  GroupsIdVisitsGet200ResponseBuilder() {
    GroupsIdVisitsGet200Response._defaults(this);
  }

  GroupsIdVisitsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _visits = $v.visits?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GroupsIdVisitsGet200Response other) {
    _$v = other as _$GroupsIdVisitsGet200Response;
  }

  @override
  void update(void Function(GroupsIdVisitsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GroupsIdVisitsGet200Response build() => _build();

  _$GroupsIdVisitsGet200Response _build() {
    _$GroupsIdVisitsGet200Response _$result;
    try {
      _$result =
          _$v ?? _$GroupsIdVisitsGet200Response._(visits: _visits?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'visits';
        _visits?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GroupsIdVisitsGet200Response',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
