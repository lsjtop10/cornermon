// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_broadcast_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MessagesBroadcastPostRequest extends MessagesBroadcastPostRequest {
  @override
  final String content;

  factory _$MessagesBroadcastPostRequest([
    void Function(MessagesBroadcastPostRequestBuilder)? updates,
  ]) => (MessagesBroadcastPostRequestBuilder()..update(updates))._build();

  _$MessagesBroadcastPostRequest._({required this.content}) : super._();
  @override
  MessagesBroadcastPostRequest rebuild(
    void Function(MessagesBroadcastPostRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MessagesBroadcastPostRequestBuilder toBuilder() =>
      MessagesBroadcastPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MessagesBroadcastPostRequest && content == other.content;
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
    return (newBuiltValueToStringHelper(
      r'MessagesBroadcastPostRequest',
    )..add('content', content)).toString();
  }
}

class MessagesBroadcastPostRequestBuilder
    implements
        Builder<
          MessagesBroadcastPostRequest,
          MessagesBroadcastPostRequestBuilder
        > {
  _$MessagesBroadcastPostRequest? _$v;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  MessagesBroadcastPostRequestBuilder() {
    MessagesBroadcastPostRequest._defaults(this);
  }

  MessagesBroadcastPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MessagesBroadcastPostRequest other) {
    _$v = other as _$MessagesBroadcastPostRequest;
  }

  @override
  void update(void Function(MessagesBroadcastPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MessagesBroadcastPostRequest build() => _build();

  _$MessagesBroadcastPostRequest _build() {
    final _$result =
        _$v ??
        _$MessagesBroadcastPostRequest._(
          content: BuiltValueNullFieldError.checkNotNull(
            content,
            r'MessagesBroadcastPostRequest',
            'content',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
