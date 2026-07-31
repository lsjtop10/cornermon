// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bulk_update_corners_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BulkUpdateCornersRequest extends BulkUpdateCornersRequest {
  @override
  final BuiltList<BulkUpdateCornersRequestCornersInner>? corners;

  factory _$BulkUpdateCornersRequest(
          [void Function(BulkUpdateCornersRequestBuilder)? updates]) =>
      (BulkUpdateCornersRequestBuilder()..update(updates))._build();

  _$BulkUpdateCornersRequest._({this.corners}) : super._();
  @override
  BulkUpdateCornersRequest rebuild(
          void Function(BulkUpdateCornersRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BulkUpdateCornersRequestBuilder toBuilder() =>
      BulkUpdateCornersRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BulkUpdateCornersRequest && corners == other.corners;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, corners.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BulkUpdateCornersRequest')
          ..add('corners', corners))
        .toString();
  }
}

class BulkUpdateCornersRequestBuilder
    implements
        Builder<BulkUpdateCornersRequest, BulkUpdateCornersRequestBuilder> {
  _$BulkUpdateCornersRequest? _$v;

  ListBuilder<BulkUpdateCornersRequestCornersInner>? _corners;
  ListBuilder<BulkUpdateCornersRequestCornersInner> get corners =>
      _$this._corners ??= ListBuilder<BulkUpdateCornersRequestCornersInner>();
  set corners(ListBuilder<BulkUpdateCornersRequestCornersInner>? corners) =>
      _$this._corners = corners;

  BulkUpdateCornersRequestBuilder() {
    BulkUpdateCornersRequest._defaults(this);
  }

  BulkUpdateCornersRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _corners = $v.corners?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BulkUpdateCornersRequest other) {
    _$v = other as _$BulkUpdateCornersRequest;
  }

  @override
  void update(void Function(BulkUpdateCornersRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BulkUpdateCornersRequest build() => _build();

  _$BulkUpdateCornersRequest _build() {
    _$BulkUpdateCornersRequest _$result;
    try {
      _$result = _$v ??
          _$BulkUpdateCornersRequest._(
            corners: _corners?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'corners';
        _corners?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BulkUpdateCornersRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
