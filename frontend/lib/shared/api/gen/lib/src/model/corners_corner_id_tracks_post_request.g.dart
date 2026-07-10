// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corners_corner_id_tracks_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CornersCornerIdTracksPostRequest
    extends CornersCornerIdTracksPostRequest {
  @override
  final int? count;

  factory _$CornersCornerIdTracksPostRequest(
          [void Function(CornersCornerIdTracksPostRequestBuilder)? updates]) =>
      (CornersCornerIdTracksPostRequestBuilder()..update(updates))._build();

  _$CornersCornerIdTracksPostRequest._({this.count}) : super._();
  @override
  CornersCornerIdTracksPostRequest rebuild(
          void Function(CornersCornerIdTracksPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CornersCornerIdTracksPostRequestBuilder toBuilder() =>
      CornersCornerIdTracksPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CornersCornerIdTracksPostRequest && count == other.count;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CornersCornerIdTracksPostRequest')
          ..add('count', count))
        .toString();
  }
}

class CornersCornerIdTracksPostRequestBuilder
    implements
        Builder<CornersCornerIdTracksPostRequest,
            CornersCornerIdTracksPostRequestBuilder> {
  _$CornersCornerIdTracksPostRequest? _$v;

  int? _count;
  int? get count => _$this._count;
  set count(int? count) => _$this._count = count;

  CornersCornerIdTracksPostRequestBuilder() {
    CornersCornerIdTracksPostRequest._defaults(this);
  }

  CornersCornerIdTracksPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _count = $v.count;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CornersCornerIdTracksPostRequest other) {
    _$v = other as _$CornersCornerIdTracksPostRequest;
  }

  @override
  void update(void Function(CornersCornerIdTracksPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CornersCornerIdTracksPostRequest build() => _build();

  _$CornersCornerIdTracksPostRequest _build() {
    final _$result = _$v ??
        _$CornersCornerIdTracksPostRequest._(
          count: count,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
