// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_camp_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateCampRequest extends CreateCampRequest {
  @override
  final DateTime? endAt;
  @override
  final String? name;
  @override
  final DateTime? startAt;

  factory _$CreateCampRequest(
          [void Function(CreateCampRequestBuilder)? updates]) =>
      (CreateCampRequestBuilder()..update(updates))._build();

  _$CreateCampRequest._({this.endAt, this.name, this.startAt}) : super._();
  @override
  CreateCampRequest rebuild(void Function(CreateCampRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateCampRequestBuilder toBuilder() =>
      CreateCampRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateCampRequest &&
        endAt == other.endAt &&
        name == other.name &&
        startAt == other.startAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, endAt.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, startAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateCampRequest')
          ..add('endAt', endAt)
          ..add('name', name)
          ..add('startAt', startAt))
        .toString();
  }
}

class CreateCampRequestBuilder
    implements Builder<CreateCampRequest, CreateCampRequestBuilder> {
  _$CreateCampRequest? _$v;

  DateTime? _endAt;
  DateTime? get endAt => _$this._endAt;
  set endAt(DateTime? endAt) => _$this._endAt = endAt;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DateTime? _startAt;
  DateTime? get startAt => _$this._startAt;
  set startAt(DateTime? startAt) => _$this._startAt = startAt;

  CreateCampRequestBuilder() {
    CreateCampRequest._defaults(this);
  }

  CreateCampRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _endAt = $v.endAt;
      _name = $v.name;
      _startAt = $v.startAt;
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
          endAt: endAt,
          name: name,
          startAt: startAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
