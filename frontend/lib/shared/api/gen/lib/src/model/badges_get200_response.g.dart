// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badges_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BadgesGet200Response extends BadgesGet200Response {
  @override
  final BuiltList<Badge>? badges;

  factory _$BadgesGet200Response([
    void Function(BadgesGet200ResponseBuilder)? updates,
  ]) => (BadgesGet200ResponseBuilder()..update(updates))._build();

  _$BadgesGet200Response._({this.badges}) : super._();
  @override
  BadgesGet200Response rebuild(
    void Function(BadgesGet200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  BadgesGet200ResponseBuilder toBuilder() =>
      BadgesGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BadgesGet200Response && badges == other.badges;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, badges.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'BadgesGet200Response',
    )..add('badges', badges)).toString();
  }
}

class BadgesGet200ResponseBuilder
    implements Builder<BadgesGet200Response, BadgesGet200ResponseBuilder> {
  _$BadgesGet200Response? _$v;

  ListBuilder<Badge>? _badges;
  ListBuilder<Badge> get badges => _$this._badges ??= ListBuilder<Badge>();
  set badges(ListBuilder<Badge>? badges) => _$this._badges = badges;

  BadgesGet200ResponseBuilder() {
    BadgesGet200Response._defaults(this);
  }

  BadgesGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _badges = $v.badges?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BadgesGet200Response other) {
    _$v = other as _$BadgesGet200Response;
  }

  @override
  void update(void Function(BadgesGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BadgesGet200Response build() => _build();

  _$BadgesGet200Response _build() {
    _$BadgesGet200Response _$result;
    try {
      _$result = _$v ?? _$BadgesGet200Response._(badges: _badges?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'badges';
        _badges?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'BadgesGet200Response',
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
