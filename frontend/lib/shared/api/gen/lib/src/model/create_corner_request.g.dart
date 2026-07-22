// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'create_corner_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateCornerRequest extends CreateCornerRequest {
  @override
  final String? campId;
  @override
  final String? name;
  @override
  final int? targetMinutes;

  factory _$CreateCornerRequest(
          [void Function(CreateCornerRequestBuilder)? updates]) =>
      (CreateCornerRequestBuilder()..update(updates))._build();

  _$CreateCornerRequest._({this.campId, this.name, this.targetMinutes})
      : super._();
  @override
  CreateCornerRequest rebuild(
          void Function(CreateCornerRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateCornerRequestBuilder toBuilder() =>
      CreateCornerRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateCornerRequest &&
        campId == other.campId &&
        name == other.name &&
        targetMinutes == other.targetMinutes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, campId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, targetMinutes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateCornerRequest')
          ..add('campId', campId)
          ..add('name', name)
          ..add('targetMinutes', targetMinutes))
        .toString();
  }
}

class CreateCornerRequestBuilder
    implements Builder<CreateCornerRequest, CreateCornerRequestBuilder> {
  _$CreateCornerRequest? _$v;

  String? _campId;
  String? get campId => _$this._campId;
  set campId(String? campId) => _$this._campId = campId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _targetMinutes;
  int? get targetMinutes => _$this._targetMinutes;
  set targetMinutes(int? targetMinutes) =>
      _$this._targetMinutes = targetMinutes;

  CreateCornerRequestBuilder() {
    CreateCornerRequest._defaults(this);
  }

  CreateCornerRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _campId = $v.campId;
      _name = $v.name;
      _targetMinutes = $v.targetMinutes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateCornerRequest other) {
    _$v = other as _$CreateCornerRequest;
  }

  @override
  void update(void Function(CreateCornerRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateCornerRequest build() => _build();

  _$CreateCornerRequest _build() {
    final _$result = _$v ??
        _$CreateCornerRequest._(
          campId: campId,
          name: name,
          targetMinutes: targetMinutes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
