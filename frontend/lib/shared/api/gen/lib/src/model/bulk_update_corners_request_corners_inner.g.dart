// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bulk_update_corners_request_corners_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BulkUpdateCornersRequestCornersInner
    extends BulkUpdateCornersRequestCornersInner {
  @override
  final String? id;
  @override
  final String? name;
  @override
  final int? targetMinutes;

  factory _$BulkUpdateCornersRequestCornersInner(
          [void Function(BulkUpdateCornersRequestCornersInnerBuilder)?
              updates]) =>
      (BulkUpdateCornersRequestCornersInnerBuilder()..update(updates))._build();

  _$BulkUpdateCornersRequestCornersInner._(
      {this.id, this.name, this.targetMinutes})
      : super._();
  @override
  BulkUpdateCornersRequestCornersInner rebuild(
          void Function(BulkUpdateCornersRequestCornersInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BulkUpdateCornersRequestCornersInnerBuilder toBuilder() =>
      BulkUpdateCornersRequestCornersInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BulkUpdateCornersRequestCornersInner &&
        id == other.id &&
        name == other.name &&
        targetMinutes == other.targetMinutes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, targetMinutes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BulkUpdateCornersRequestCornersInner')
          ..add('id', id)
          ..add('name', name)
          ..add('targetMinutes', targetMinutes))
        .toString();
  }
}

class BulkUpdateCornersRequestCornersInnerBuilder
    implements
        Builder<BulkUpdateCornersRequestCornersInner,
            BulkUpdateCornersRequestCornersInnerBuilder> {
  _$BulkUpdateCornersRequestCornersInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _targetMinutes;
  int? get targetMinutes => _$this._targetMinutes;
  set targetMinutes(int? targetMinutes) =>
      _$this._targetMinutes = targetMinutes;

  BulkUpdateCornersRequestCornersInnerBuilder() {
    BulkUpdateCornersRequestCornersInner._defaults(this);
  }

  BulkUpdateCornersRequestCornersInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _targetMinutes = $v.targetMinutes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BulkUpdateCornersRequestCornersInner other) {
    _$v = other as _$BulkUpdateCornersRequestCornersInner;
  }

  @override
  void update(
      void Function(BulkUpdateCornersRequestCornersInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BulkUpdateCornersRequestCornersInner build() => _build();

  _$BulkUpdateCornersRequestCornersInner _build() {
    final _$result = _$v ??
        _$BulkUpdateCornersRequestCornersInner._(
          id: id,
          name: name,
          targetMinutes: targetMinutes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
