// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_camp_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateCampRequest extends CreateCampRequest {
  @override
  final String? name;

  factory _$CreateCampRequest(
          [void Function(CreateCampRequestBuilder)? updates]) =>
      (CreateCampRequestBuilder()..update(updates))._build();

  _$CreateCampRequest._({this.name}) : super._();
  @override
  CreateCampRequest rebuild(void Function(CreateCampRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateCampRequestBuilder toBuilder() =>
      CreateCampRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateCampRequest && name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateCampRequest')
          ..add('name', name))
        .toString();
  }
}

class CreateCampRequestBuilder
    implements Builder<CreateCampRequest, CreateCampRequestBuilder> {
  _$CreateCampRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  CreateCampRequestBuilder() {
    CreateCampRequest._defaults(this);
  }

  CreateCampRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateCampRequest other) {
    _$v = other as _$CreateCampRequest;
  }

  @override
  void update(void Function(CreateCampRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateCampRequest build() => _build();

  _$CreateCampRequest _build() {
    final _$result = _$v ??
        _$CreateCampRequest._(
          name: name,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
