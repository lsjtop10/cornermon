// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corners_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CornersPostRequest extends CornersPostRequest {
  @override
  final BuiltList<CornersPostRequestCornersInner> corners;

  factory _$CornersPostRequest([
    void Function(CornersPostRequestBuilder)? updates,
  ]) => (CornersPostRequestBuilder()..update(updates))._build();

  _$CornersPostRequest._({required this.corners}) : super._();
  @override
  CornersPostRequest rebuild(
    void Function(CornersPostRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CornersPostRequestBuilder toBuilder() =>
      CornersPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CornersPostRequest && corners == other.corners;
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
    return (newBuiltValueToStringHelper(
      r'CornersPostRequest',
    )..add('corners', corners)).toString();
  }
}

class CornersPostRequestBuilder
    implements Builder<CornersPostRequest, CornersPostRequestBuilder> {
  _$CornersPostRequest? _$v;

  ListBuilder<CornersPostRequestCornersInner>? _corners;
  ListBuilder<CornersPostRequestCornersInner> get corners =>
      _$this._corners ??= ListBuilder<CornersPostRequestCornersInner>();
  set corners(ListBuilder<CornersPostRequestCornersInner>? corners) =>
      _$this._corners = corners;

  CornersPostRequestBuilder() {
    CornersPostRequest._defaults(this);
  }

  CornersPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _corners = $v.corners.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CornersPostRequest other) {
    _$v = other as _$CornersPostRequest;
  }

  @override
  void update(void Function(CornersPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CornersPostRequest build() => _build();

  _$CornersPostRequest _build() {
    _$CornersPostRequest _$result;
    try {
      _$result = _$v ?? _$CornersPostRequest._(corners: corners.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'corners';
        corners.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'CornersPostRequest',
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
