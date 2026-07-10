// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_sse_snapshot.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminSseSnapshot extends AdminSseSnapshot {
  @override
  final BuiltList<Corner>? corners;
  @override
  final BuiltList<Group>? groups;
  @override
  final int? unreadBroadcastCount;

  factory _$AdminSseSnapshot(
          [void Function(AdminSseSnapshotBuilder)? updates]) =>
      (AdminSseSnapshotBuilder()..update(updates))._build();

  _$AdminSseSnapshot._({this.corners, this.groups, this.unreadBroadcastCount})
      : super._();
  @override
  AdminSseSnapshot rebuild(void Function(AdminSseSnapshotBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminSseSnapshotBuilder toBuilder() =>
      AdminSseSnapshotBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminSseSnapshot &&
        corners == other.corners &&
        groups == other.groups &&
        unreadBroadcastCount == other.unreadBroadcastCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, corners.hashCode);
    _$hash = $jc(_$hash, groups.hashCode);
    _$hash = $jc(_$hash, unreadBroadcastCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminSseSnapshot')
          ..add('corners', corners)
          ..add('groups', groups)
          ..add('unreadBroadcastCount', unreadBroadcastCount))
        .toString();
  }
}

class AdminSseSnapshotBuilder
    implements Builder<AdminSseSnapshot, AdminSseSnapshotBuilder> {
  _$AdminSseSnapshot? _$v;

  ListBuilder<Corner>? _corners;
  ListBuilder<Corner> get corners => _$this._corners ??= ListBuilder<Corner>();
  set corners(ListBuilder<Corner>? corners) => _$this._corners = corners;

  ListBuilder<Group>? _groups;
  ListBuilder<Group> get groups => _$this._groups ??= ListBuilder<Group>();
  set groups(ListBuilder<Group>? groups) => _$this._groups = groups;

  int? _unreadBroadcastCount;
  int? get unreadBroadcastCount => _$this._unreadBroadcastCount;
  set unreadBroadcastCount(int? unreadBroadcastCount) =>
      _$this._unreadBroadcastCount = unreadBroadcastCount;

  AdminSseSnapshotBuilder() {
    AdminSseSnapshot._defaults(this);
  }

  AdminSseSnapshotBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _corners = $v.corners?.toBuilder();
      _groups = $v.groups?.toBuilder();
      _unreadBroadcastCount = $v.unreadBroadcastCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminSseSnapshot other) {
    _$v = other as _$AdminSseSnapshot;
  }

  @override
  void update(void Function(AdminSseSnapshotBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminSseSnapshot build() => _build();

  _$AdminSseSnapshot _build() {
    _$AdminSseSnapshot _$result;
    try {
      _$result = _$v ??
          _$AdminSseSnapshot._(
            corners: _corners?.build(),
            groups: _groups?.build(),
            unreadBroadcastCount: unreadBroadcastCount,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'corners';
        _corners?.build();
        _$failedField = 'groups';
        _groups?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdminSseSnapshot', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
