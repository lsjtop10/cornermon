// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_message_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DirectMessageRequest extends DirectMessageRequest {
  @override
  final String? content;

  factory _$DirectMessageRequest(
          [void Function(DirectMessageRequestBuilder)? updates]) =>
      (DirectMessageRequestBuilder()..update(updates))._build();

  _$DirectMessageRequest._({this.content}) : super._();
  @override
  DirectMessageRequest rebuild(
          void Function(DirectMessageRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DirectMessageRequestBuilder toBuilder() =>
      DirectMessageRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectMessageRequest && content == other.content;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DirectMessageRequest')
          ..add('content', content))
        .toString();
  }
}

class DirectMessageRequestBuilder
    implements Builder<DirectMessageRequest, DirectMessageRequestBuilder> {
  _$DirectMessageRequest? _$v;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  DirectMessageRequestBuilder() {
    DirectMessageRequest._defaults(this);
  }

  DirectMessageRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DirectMessageRequest other) {
    _$v = other as _$DirectMessageRequest;
  }

  @override
  void update(void Function(DirectMessageRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DirectMessageRequest build() => _build();

  _$DirectMessageRequest _build() {
    final _$result = _$v ??
        _$DirectMessageRequest._(
          content: content,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
