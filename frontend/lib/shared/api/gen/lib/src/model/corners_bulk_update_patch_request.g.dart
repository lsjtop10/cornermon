// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corners_bulk_update_patch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CornersBulkUpdatePatchRequest extends CornersBulkUpdatePatchRequest {
  @override
  final BuiltList<String> cornerIds;
  @override
  final int targetMinutes;

  factory _$CornersBulkUpdatePatchRequest([
    void Function(CornersBulkUpdatePatchRequestBuilder)? updates,
  ]) => (CornersBulkUpdatePatchRequestBuilder()..update(updates))._build();

  _$CornersBulkUpdatePatchRequest._({
    required this.cornerIds,
    required this.targetMinutes,
  }) : super._();
  @override
  CornersBulkUpdatePatchRequest rebuild(
    void Function(CornersBulkUpdatePatchRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CornersBulkUpdatePatchRequestBuilder toBuilder() =>
      CornersBulkUpdatePatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CornersBulkUpdatePatchRequest &&
        cornerIds == other.cornerIds &&
        targetMinutes == other.targetMinutes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cornerIds.hashCode);
    _$hash = $jc(_$hash, targetMinutes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CornersBulkUpdatePatchRequest')
          ..add('cornerIds', cornerIds)
          ..add('targetMinutes', targetMinutes))
        .toString();
  }
}

class CornersBulkUpdatePatchRequestBuilder
    implements
        Builder<
          CornersBulkUpdatePatchRequest,
          CornersBulkUpdatePatchRequestBuilder
        > {
  _$CornersBulkUpdatePatchRequest? _$v;

  ListBuilder<String>? _cornerIds;
  ListBuilder<String> get cornerIds =>
      _$this._cornerIds ??= ListBuilder<String>();
  set cornerIds(ListBuilder<String>? cornerIds) =>
      _$this._cornerIds = cornerIds;

  int? _targetMinutes;
  int? get targetMinutes => _$this._targetMinutes;
  set targetMinutes(int? targetMinutes) =>
      _$this._targetMinutes = targetMinutes;

  CornersBulkUpdatePatchRequestBuilder() {
    CornersBulkUpdatePatchRequest._defaults(this);
  }

  CornersBulkUpdatePatchRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cornerIds = $v.cornerIds.toBuilder();
      _targetMinutes = $v.targetMinutes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CornersBulkUpdatePatchRequest other) {
    _$v = other as _$CornersBulkUpdatePatchRequest;
  }

  @override
  void update(void Function(CornersBulkUpdatePatchRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CornersBulkUpdatePatchRequest build() => _build();

  _$CornersBulkUpdatePatchRequest _build() {
    _$CornersBulkUpdatePatchRequest _$result;
    try {
      _$result =
          _$v ??
          _$CornersBulkUpdatePatchRequest._(
            cornerIds: cornerIds.build(),
            targetMinutes: BuiltValueNullFieldError.checkNotNull(
              targetMinutes,
              r'CornersBulkUpdatePatchRequest',
              'targetMinutes',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'cornerIds';
        cornerIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'CornersBulkUpdatePatchRequest',
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
