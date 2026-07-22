// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'broadcast_message_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BroadcastMessageRequest extends BroadcastMessageRequest {
  @override
  final String? content;

  factory _$BroadcastMessageRequest(
          [void Function(BroadcastMessageRequestBuilder)? updates]) =>
      (BroadcastMessageRequestBuilder()..update(updates))._build();

  _$BroadcastMessageRequest._({this.content}) : super._();
  @override
  BroadcastMessageRequest rebuild(
          void Function(BroadcastMessageRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BroadcastMessageRequestBuilder toBuilder() =>
      BroadcastMessageRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BroadcastMessageRequest && content == other.content;
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
    return (newBuiltValueToStringHelper(r'BroadcastMessageRequest')
          ..add('content', content))
        .toString();
  }
}

class BroadcastMessageRequestBuilder
    implements
        Builder<BroadcastMessageRequest, BroadcastMessageRequestBuilder> {
  _$BroadcastMessageRequest? _$v;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  BroadcastMessageRequestBuilder() {
    BroadcastMessageRequest._defaults(this);
  }

  BroadcastMessageRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BroadcastMessageRequest other) {
    _$v = other as _$BroadcastMessageRequest;
  }

  @override
  void update(void Function(BroadcastMessageRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BroadcastMessageRequest build() => _build();

  _$BroadcastMessageRequest _build() {
    final _$result = _$v ??
        _$BroadcastMessageRequest._(
          content: content,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
