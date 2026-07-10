// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badges_bulk_generate_post201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BadgesBulkGeneratePost201Response
    extends BadgesBulkGeneratePost201Response {
  @override
  final BuiltList<Badge>? badges;
  @override
  final int? generatedCount;

  factory _$BadgesBulkGeneratePost201Response([
    void Function(BadgesBulkGeneratePost201ResponseBuilder)? updates,
  ]) => (BadgesBulkGeneratePost201ResponseBuilder()..update(updates))._build();

  _$BadgesBulkGeneratePost201Response._({this.badges, this.generatedCount})
    : super._();
  @override
  BadgesBulkGeneratePost201Response rebuild(
    void Function(BadgesBulkGeneratePost201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  BadgesBulkGeneratePost201ResponseBuilder toBuilder() =>
      BadgesBulkGeneratePost201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BadgesBulkGeneratePost201Response &&
        badges == other.badges &&
        generatedCount == other.generatedCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, badges.hashCode);
    _$hash = $jc(_$hash, generatedCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BadgesBulkGeneratePost201Response')
          ..add('badges', badges)
          ..add('generatedCount', generatedCount))
        .toString();
  }
}

class BadgesBulkGeneratePost201ResponseBuilder
    implements
        Builder<
          BadgesBulkGeneratePost201Response,
          BadgesBulkGeneratePost201ResponseBuilder
        > {
  _$BadgesBulkGeneratePost201Response? _$v;

  ListBuilder<Badge>? _badges;
  ListBuilder<Badge> get badges => _$this._badges ??= ListBuilder<Badge>();
  set badges(ListBuilder<Badge>? badges) => _$this._badges = badges;

  int? _generatedCount;
  int? get generatedCount => _$this._generatedCount;
  set generatedCount(int? generatedCount) =>
      _$this._generatedCount = generatedCount;

  BadgesBulkGeneratePost201ResponseBuilder() {
    BadgesBulkGeneratePost201Response._defaults(this);
  }

  BadgesBulkGeneratePost201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _badges = $v.badges?.toBuilder();
      _generatedCount = $v.generatedCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BadgesBulkGeneratePost201Response other) {
    _$v = other as _$BadgesBulkGeneratePost201Response;
  }

  @override
  void update(
    void Function(BadgesBulkGeneratePost201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  BadgesBulkGeneratePost201Response build() => _build();

  _$BadgesBulkGeneratePost201Response _build() {
    _$BadgesBulkGeneratePost201Response _$result;
    try {
      _$result =
          _$v ??
          _$BadgesBulkGeneratePost201Response._(
            badges: _badges?.build(),
            generatedCount: generatedCount,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'badges';
        _badges?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'BadgesBulkGeneratePost201Response',
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
