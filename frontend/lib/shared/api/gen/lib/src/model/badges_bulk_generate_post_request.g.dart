// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badges_bulk_generate_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BadgesBulkGeneratePostRequest extends BadgesBulkGeneratePostRequest {
  @override
  final int count;

  factory _$BadgesBulkGeneratePostRequest([
    void Function(BadgesBulkGeneratePostRequestBuilder)? updates,
  ]) => (BadgesBulkGeneratePostRequestBuilder()..update(updates))._build();

  _$BadgesBulkGeneratePostRequest._({required this.count}) : super._();
  @override
  BadgesBulkGeneratePostRequest rebuild(
    void Function(BadgesBulkGeneratePostRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  BadgesBulkGeneratePostRequestBuilder toBuilder() =>
      BadgesBulkGeneratePostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BadgesBulkGeneratePostRequest && count == other.count;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'BadgesBulkGeneratePostRequest',
    )..add('count', count)).toString();
  }
}

class BadgesBulkGeneratePostRequestBuilder
    implements
        Builder<
          BadgesBulkGeneratePostRequest,
          BadgesBulkGeneratePostRequestBuilder
        > {
  _$BadgesBulkGeneratePostRequest? _$v;

  int? _count;
  int? get count => _$this._count;
  set count(int? count) => _$this._count = count;

  BadgesBulkGeneratePostRequestBuilder() {
    BadgesBulkGeneratePostRequest._defaults(this);
  }

  BadgesBulkGeneratePostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _count = $v.count;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BadgesBulkGeneratePostRequest other) {
    _$v = other as _$BadgesBulkGeneratePostRequest;
  }

  @override
  void update(void Function(BadgesBulkGeneratePostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BadgesBulkGeneratePostRequest build() => _build();

  _$BadgesBulkGeneratePostRequest _build() {
    final _$result =
        _$v ??
        _$BadgesBulkGeneratePostRequest._(
          count: BuiltValueNullFieldError.checkNotNull(
            count,
            r'BadgesBulkGeneratePostRequest',
            'count',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
