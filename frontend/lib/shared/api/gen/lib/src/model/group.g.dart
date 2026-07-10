// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Group extends Group {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? badgeId;
  @override
  final GroupStatus status;
  @override
  final bool isFinished;
  @override
  final BuiltList<CornerProgress> itinerary;

  factory _$Group([void Function(GroupBuilder)? updates]) =>
      (GroupBuilder()..update(updates))._build();

  _$Group._(
      {required this.id,
      required this.name,
      this.badgeId,
      required this.status,
      required this.isFinished,
      required this.itinerary})
      : super._();
  @override
  Group rebuild(void Function(GroupBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GroupBuilder toBuilder() => GroupBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Group &&
        id == other.id &&
        name == other.name &&
        badgeId == other.badgeId &&
        status == other.status &&
        isFinished == other.isFinished &&
        itinerary == other.itinerary;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, badgeId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, isFinished.hashCode);
    _$hash = $jc(_$hash, itinerary.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Group')
          ..add('id', id)
          ..add('name', name)
          ..add('badgeId', badgeId)
          ..add('status', status)
          ..add('isFinished', isFinished)
          ..add('itinerary', itinerary))
        .toString();
  }
}

class GroupBuilder implements Builder<Group, GroupBuilder> {
  _$Group? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _badgeId;
  String? get badgeId => _$this._badgeId;
  set badgeId(String? badgeId) => _$this._badgeId = badgeId;

  GroupStatus? _status;
  GroupStatus? get status => _$this._status;
  set status(GroupStatus? status) => _$this._status = status;

  bool? _isFinished;
  bool? get isFinished => _$this._isFinished;
  set isFinished(bool? isFinished) => _$this._isFinished = isFinished;

  ListBuilder<CornerProgress>? _itinerary;
  ListBuilder<CornerProgress> get itinerary =>
      _$this._itinerary ??= ListBuilder<CornerProgress>();
  set itinerary(ListBuilder<CornerProgress>? itinerary) =>
      _$this._itinerary = itinerary;

  GroupBuilder() {
    Group._defaults(this);
  }

  GroupBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _badgeId = $v.badgeId;
      _status = $v.status;
      _isFinished = $v.isFinished;
      _itinerary = $v.itinerary.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Group other) {
    _$v = other as _$Group;
  }

  @override
  void update(void Function(GroupBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Group build() => _build();

  _$Group _build() {
    _$Group _$result;
    try {
      _$result = _$v ??
          _$Group._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Group', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(name, r'Group', 'name'),
            badgeId: badgeId,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'Group', 'status'),
            isFinished: BuiltValueNullFieldError.checkNotNull(
                isFinished, r'Group', 'isFinished'),
            itinerary: itinerary.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'itinerary';
        itinerary.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Group', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
