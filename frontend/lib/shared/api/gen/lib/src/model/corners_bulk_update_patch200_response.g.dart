// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corners_bulk_update_patch200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CornersBulkUpdatePatch200Response
    extends CornersBulkUpdatePatch200Response {
  @override
  final int? updatedCount;

  factory _$CornersBulkUpdatePatch200Response([
    void Function(CornersBulkUpdatePatch200ResponseBuilder)? updates,
  ]) => (CornersBulkUpdatePatch200ResponseBuilder()..update(updates))._build();

  _$CornersBulkUpdatePatch200Response._({this.updatedCount}) : super._();
  @override
  CornersBulkUpdatePatch200Response rebuild(
    void Function(CornersBulkUpdatePatch200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CornersBulkUpdatePatch200ResponseBuilder toBuilder() =>
      CornersBulkUpdatePatch200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CornersBulkUpdatePatch200Response &&
        updatedCount == other.updatedCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, updatedCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'CornersBulkUpdatePatch200Response',
    )..add('updatedCount', updatedCount)).toString();
  }
}

class CornersBulkUpdatePatch200ResponseBuilder
    implements
        Builder<
          CornersBulkUpdatePatch200Response,
          CornersBulkUpdatePatch200ResponseBuilder
        > {
  _$CornersBulkUpdatePatch200Response? _$v;

  int? _updatedCount;
  int? get updatedCount => _$this._updatedCount;
  set updatedCount(int? updatedCount) => _$this._updatedCount = updatedCount;

  CornersBulkUpdatePatch200ResponseBuilder() {
    CornersBulkUpdatePatch200Response._defaults(this);
  }

  CornersBulkUpdatePatch200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _updatedCount = $v.updatedCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CornersBulkUpdatePatch200Response other) {
    _$v = other as _$CornersBulkUpdatePatch200Response;
  }

  @override
  void update(
    void Function(CornersBulkUpdatePatch200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  CornersBulkUpdatePatch200Response build() => _build();

  _$CornersBulkUpdatePatch200Response _build() {
    final _$result =
        _$v ??
        _$CornersBulkUpdatePatch200Response._(updatedCount: updatedCount);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
