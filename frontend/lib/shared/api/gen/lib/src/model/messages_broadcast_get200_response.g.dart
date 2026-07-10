// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_broadcast_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MessagesBroadcastGet200Response
    extends MessagesBroadcastGet200Response {
  @override
  final BuiltList<Message>? messages;

  factory _$MessagesBroadcastGet200Response(
          [void Function(MessagesBroadcastGet200ResponseBuilder)? updates]) =>
      (MessagesBroadcastGet200ResponseBuilder()..update(updates))._build();

  _$MessagesBroadcastGet200Response._({this.messages}) : super._();
  @override
  MessagesBroadcastGet200Response rebuild(
          void Function(MessagesBroadcastGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MessagesBroadcastGet200ResponseBuilder toBuilder() =>
      MessagesBroadcastGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MessagesBroadcastGet200Response &&
        messages == other.messages;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, messages.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MessagesBroadcastGet200Response')
          ..add('messages', messages))
        .toString();
  }
}

class MessagesBroadcastGet200ResponseBuilder
    implements
        Builder<MessagesBroadcastGet200Response,
            MessagesBroadcastGet200ResponseBuilder> {
  _$MessagesBroadcastGet200Response? _$v;

  ListBuilder<Message>? _messages;
  ListBuilder<Message> get messages =>
      _$this._messages ??= ListBuilder<Message>();
  set messages(ListBuilder<Message>? messages) => _$this._messages = messages;

  MessagesBroadcastGet200ResponseBuilder() {
    MessagesBroadcastGet200Response._defaults(this);
  }

  MessagesBroadcastGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _messages = $v.messages?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MessagesBroadcastGet200Response other) {
    _$v = other as _$MessagesBroadcastGet200Response;
  }

  @override
  void update(void Function(MessagesBroadcastGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MessagesBroadcastGet200Response build() => _build();

  _$MessagesBroadcastGet200Response _build() {
    _$MessagesBroadcastGet200Response _$result;
    try {
      _$result = _$v ??
          _$MessagesBroadcastGet200Response._(
            messages: _messages?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'messages';
        _messages?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MessagesBroadcastGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
