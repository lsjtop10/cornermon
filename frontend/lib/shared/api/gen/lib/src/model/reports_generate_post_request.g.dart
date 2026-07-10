// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_generate_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReportsGeneratePostRequest extends ReportsGeneratePostRequest {
  @override
  final String campId;

  factory _$ReportsGeneratePostRequest(
          [void Function(ReportsGeneratePostRequestBuilder)? updates]) =>
      (ReportsGeneratePostRequestBuilder()..update(updates))._build();

  _$ReportsGeneratePostRequest._({required this.campId}) : super._();
  @override
  ReportsGeneratePostRequest rebuild(
          void Function(ReportsGeneratePostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReportsGeneratePostRequestBuilder toBuilder() =>
      ReportsGeneratePostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReportsGeneratePostRequest && campId == other.campId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, campId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReportsGeneratePostRequest')
          ..add('campId', campId))
        .toString();
  }
}

class ReportsGeneratePostRequestBuilder
    implements
        Builder<ReportsGeneratePostRequest, ReportsGeneratePostRequestBuilder> {
  _$ReportsGeneratePostRequest? _$v;

  String? _campId;
  String? get campId => _$this._campId;
  set campId(String? campId) => _$this._campId = campId;

  ReportsGeneratePostRequestBuilder() {
    ReportsGeneratePostRequest._defaults(this);
  }

  ReportsGeneratePostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _campId = $v.campId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReportsGeneratePostRequest other) {
    _$v = other as _$ReportsGeneratePostRequest;
  }

  @override
  void update(void Function(ReportsGeneratePostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReportsGeneratePostRequest build() => _build();

  _$ReportsGeneratePostRequest _build() {
    final _$result = _$v ??
        _$ReportsGeneratePostRequest._(
          campId: BuiltValueNullFieldError.checkNotNull(
              campId, r'ReportsGeneratePostRequest', 'campId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
