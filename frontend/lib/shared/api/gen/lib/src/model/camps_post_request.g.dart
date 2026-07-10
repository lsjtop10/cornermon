// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camps_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CampsPostRequest extends CampsPostRequest {
  @override
  final String name;
  @override
  final DateTime startAt;
  @override
  final DateTime endAt;

  factory _$CampsPostRequest(
          [void Function(CampsPostRequestBuilder)? updates]) =>
      (CampsPostRequestBuilder()..update(updates))._build();

  _$CampsPostRequest._(
      {required this.name, required this.startAt, required this.endAt})
      : super._();
  @override
  CampsPostRequest rebuild(void Function(CampsPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CampsPostRequestBuilder toBuilder() =>
      CampsPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CampsPostRequest &&
        name == other.name &&
        startAt == other.startAt &&
        endAt == other.endAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, startAt.hashCode);
    _$hash = $jc(_$hash, endAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CampsPostRequest')
          ..add('name', name)
          ..add('startAt', startAt)
          ..add('endAt', endAt))
        .toString();
  }
}

class CampsPostRequestBuilder
    implements Builder<CampsPostRequest, CampsPostRequestBuilder> {
  _$CampsPostRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DateTime? _startAt;
  DateTime? get startAt => _$this._startAt;
  set startAt(DateTime? startAt) => _$this._startAt = startAt;

  DateTime? _endAt;
  DateTime? get endAt => _$this._endAt;
  set endAt(DateTime? endAt) => _$this._endAt = endAt;

  CampsPostRequestBuilder() {
    CampsPostRequest._defaults(this);
  }

  CampsPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _startAt = $v.startAt;
      _endAt = $v.endAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CampsPostRequest other) {
    _$v = other as _$CampsPostRequest;
  }

  @override
  void update(void Function(CampsPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CampsPostRequest build() => _build();

  _$CampsPostRequest _build() {
    final _$result = _$v ??
        _$CampsPostRequest._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'CampsPostRequest', 'name'),
          startAt: BuiltValueNullFieldError.checkNotNull(
              startAt, r'CampsPostRequest', 'startAt'),
          endAt: BuiltValueNullFieldError.checkNotNull(
              endAt, r'CampsPostRequest', 'endAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
