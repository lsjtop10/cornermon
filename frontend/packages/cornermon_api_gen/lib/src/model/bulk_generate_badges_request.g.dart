// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bulk_generate_badges_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BulkGenerateBadgesRequest extends BulkGenerateBadgesRequest {
  @override
  final int? count;

  factory _$BulkGenerateBadgesRequest(
          [void Function(BulkGenerateBadgesRequestBuilder)? updates]) =>
      (BulkGenerateBadgesRequestBuilder()..update(updates))._build();

  _$BulkGenerateBadgesRequest._({this.count}) : super._();
  @override
  BulkGenerateBadgesRequest rebuild(
          void Function(BulkGenerateBadgesRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BulkGenerateBadgesRequestBuilder toBuilder() =>
      BulkGenerateBadgesRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BulkGenerateBadgesRequest && count == other.count;
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
    return (newBuiltValueToStringHelper(r'BulkGenerateBadgesRequest')
          ..add('count', count))
        .toString();
  }
}

class BulkGenerateBadgesRequestBuilder
    implements
        Builder<BulkGenerateBadgesRequest, BulkGenerateBadgesRequestBuilder> {
  _$BulkGenerateBadgesRequest? _$v;

  int? _count;
  int? get count => _$this._count;
  set count(int? count) => _$this._count = count;

  BulkGenerateBadgesRequestBuilder() {
    BulkGenerateBadgesRequest._defaults(this);
  }

  BulkGenerateBadgesRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _count = $v.count;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BulkGenerateBadgesRequest other) {
    _$v = other as _$BulkGenerateBadgesRequest;
  }

  @override
  void update(void Function(BulkGenerateBadgesRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BulkGenerateBadgesRequest build() => _build();

  _$BulkGenerateBadgesRequest _build() {
    final _$result = _$v ??
        _$BulkGenerateBadgesRequest._(
          count: count,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
