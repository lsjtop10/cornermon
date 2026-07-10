// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camps_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CampsGet200Response extends CampsGet200Response {
  @override
  final BuiltList<Camp>? camps;

  factory _$CampsGet200Response(
          [void Function(CampsGet200ResponseBuilder)? updates]) =>
      (CampsGet200ResponseBuilder()..update(updates))._build();

  _$CampsGet200Response._({this.camps}) : super._();
  @override
  CampsGet200Response rebuild(
          void Function(CampsGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CampsGet200ResponseBuilder toBuilder() =>
      CampsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CampsGet200Response && camps == other.camps;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, camps.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CampsGet200Response')
          ..add('camps', camps))
        .toString();
  }
}

class CampsGet200ResponseBuilder
    implements Builder<CampsGet200Response, CampsGet200ResponseBuilder> {
  _$CampsGet200Response? _$v;

  ListBuilder<Camp>? _camps;
  ListBuilder<Camp> get camps => _$this._camps ??= ListBuilder<Camp>();
  set camps(ListBuilder<Camp>? camps) => _$this._camps = camps;

  CampsGet200ResponseBuilder() {
    CampsGet200Response._defaults(this);
  }

  CampsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _camps = $v.camps?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CampsGet200Response other) {
    _$v = other as _$CampsGet200Response;
  }

  @override
  void update(void Function(CampsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CampsGet200Response build() => _build();

  _$CampsGet200Response _build() {
    _$CampsGet200Response _$result;
    try {
      _$result = _$v ??
          _$CampsGet200Response._(
            camps: _camps?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'camps';
        _camps?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CampsGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
