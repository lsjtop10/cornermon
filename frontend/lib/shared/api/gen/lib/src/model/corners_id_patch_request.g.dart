// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corners_id_patch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CornersIdPatchRequest extends CornersIdPatchRequest {
  @override
  final String? name;
  @override
  final int? targetMinutes;

  factory _$CornersIdPatchRequest([
    void Function(CornersIdPatchRequestBuilder)? updates,
  ]) => (CornersIdPatchRequestBuilder()..update(updates))._build();

  _$CornersIdPatchRequest._({this.name, this.targetMinutes}) : super._();
  @override
  CornersIdPatchRequest rebuild(
    void Function(CornersIdPatchRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CornersIdPatchRequestBuilder toBuilder() =>
      CornersIdPatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CornersIdPatchRequest &&
        name == other.name &&
        targetMinutes == other.targetMinutes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, targetMinutes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CornersIdPatchRequest')
          ..add('name', name)
          ..add('targetMinutes', targetMinutes))
        .toString();
  }
}

class CornersIdPatchRequestBuilder
    implements Builder<CornersIdPatchRequest, CornersIdPatchRequestBuilder> {
  _$CornersIdPatchRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _targetMinutes;
  int? get targetMinutes => _$this._targetMinutes;
  set targetMinutes(int? targetMinutes) =>
      _$this._targetMinutes = targetMinutes;

  CornersIdPatchRequestBuilder() {
    CornersIdPatchRequest._defaults(this);
  }

  CornersIdPatchRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _targetMinutes = $v.targetMinutes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CornersIdPatchRequest other) {
    _$v = other as _$CornersIdPatchRequest;
  }

  @override
  void update(void Function(CornersIdPatchRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CornersIdPatchRequest build() => _build();

  _$CornersIdPatchRequest _build() {
    final _$result =
        _$v ??
        _$CornersIdPatchRequest._(name: name, targetMinutes: targetMinutes);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
