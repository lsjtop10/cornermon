// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corners_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CornersGet200Response extends CornersGet200Response {
  @override
  final BuiltList<Corner>? corners;

  factory _$CornersGet200Response([
    void Function(CornersGet200ResponseBuilder)? updates,
  ]) => (CornersGet200ResponseBuilder()..update(updates))._build();

  _$CornersGet200Response._({this.corners}) : super._();
  @override
  CornersGet200Response rebuild(
    void Function(CornersGet200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CornersGet200ResponseBuilder toBuilder() =>
      CornersGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CornersGet200Response && corners == other.corners;
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
      r'CornersGet200Response',
    )..add('corners', corners)).toString();
  }
}

class CornersGet200ResponseBuilder
    implements Builder<CornersGet200Response, CornersGet200ResponseBuilder> {
  _$CornersGet200Response? _$v;

  ListBuilder<Corner>? _corners;
  ListBuilder<Corner> get corners => _$this._corners ??= ListBuilder<Corner>();
  set corners(ListBuilder<Corner>? corners) => _$this._corners = corners;

  CornersGet200ResponseBuilder() {
    CornersGet200Response._defaults(this);
  }

  CornersGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _corners = $v.corners?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CornersGet200Response other) {
    _$v = other as _$CornersGet200Response;
  }

  @override
  void update(void Function(CornersGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CornersGet200Response build() => _build();

  _$CornersGet200Response _build() {
    _$CornersGet200Response _$result;
    try {
      _$result = _$v ?? _$CornersGet200Response._(corners: _corners?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'corners';
        _corners?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'CornersGet200Response',
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
