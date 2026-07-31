// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_badges_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExportBadgesResponse extends ExportBadgesResponse {
  @override
  final BuiltList<BadgeResponse>? badges;

  factory _$ExportBadgesResponse(
          [void Function(ExportBadgesResponseBuilder)? updates]) =>
      (ExportBadgesResponseBuilder()..update(updates))._build();

  _$ExportBadgesResponse._({this.badges}) : super._();
  @override
  ExportBadgesResponse rebuild(
          void Function(ExportBadgesResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExportBadgesResponseBuilder toBuilder() =>
      ExportBadgesResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExportBadgesResponse && badges == other.badges;
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
    return (newBuiltValueToStringHelper(r'ExportBadgesResponse')
          ..add('badges', badges))
        .toString();
  }
}

class ExportBadgesResponseBuilder
    implements Builder<ExportBadgesResponse, ExportBadgesResponseBuilder> {
  _$ExportBadgesResponse? _$v;

  ListBuilder<BadgeResponse>? _badges;
  ListBuilder<BadgeResponse> get badges =>
      _$this._badges ??= ListBuilder<BadgeResponse>();
  set badges(ListBuilder<BadgeResponse>? badges) => _$this._badges = badges;

  ExportBadgesResponseBuilder() {
    ExportBadgesResponse._defaults(this);
  }

  ExportBadgesResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _badges = $v.badges?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExportBadgesResponse other) {
    _$v = other as _$ExportBadgesResponse;
  }

  @override
  void update(void Function(ExportBadgesResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExportBadgesResponse build() => _build();

  _$ExportBadgesResponse _build() {
    _$ExportBadgesResponse _$result;
    try {
      _$result = _$v ??
          _$ExportBadgesResponse._(
            badges: _badges?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'badges';
        _badges?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ExportBadgesResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
