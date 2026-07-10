// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MessageSenderRoleEnum _$messageSenderRoleEnum_ADMIN =
    const MessageSenderRoleEnum._('ADMIN');
const MessageSenderRoleEnum _$messageSenderRoleEnum_TRACK =
    const MessageSenderRoleEnum._('TRACK');

MessageSenderRoleEnum _$messageSenderRoleEnumValueOf(String name) {
  switch (name) {
    case 'ADMIN':
      return _$messageSenderRoleEnum_ADMIN;
    case 'TRACK':
      return _$messageSenderRoleEnum_TRACK;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MessageSenderRoleEnum> _$messageSenderRoleEnumValues =
    BuiltSet<MessageSenderRoleEnum>(const <MessageSenderRoleEnum>[
  _$messageSenderRoleEnum_ADMIN,
  _$messageSenderRoleEnum_TRACK,
]);

Serializer<MessageSenderRoleEnum> _$messageSenderRoleEnumSerializer =
    _$MessageSenderRoleEnumSerializer();

class _$MessageSenderRoleEnumSerializer
    implements PrimitiveSerializer<MessageSenderRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ADMIN': 'ADMIN',
    'TRACK': 'TRACK',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ADMIN': 'ADMIN',
    'TRACK': 'TRACK',
  };

  @override
  final Iterable<Type> types = const <Type>[MessageSenderRoleEnum];
  @override
  final String wireName = 'MessageSenderRoleEnum';

  @override
  Object serialize(Serializers serializers, MessageSenderRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MessageSenderRoleEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MessageSenderRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Message extends Message {
  @override
  final String id;
  @override
  final MessageChannelType channelType;
  @override
  final String? trackId;
  @override
  final MessageSenderRoleEnum senderRole;
  @override
  final String content;
  @override
  final DateTime sentAt;
  @override
  final DateTime? readAt;

  factory _$Message([void Function(MessageBuilder)? updates]) =>
      (MessageBuilder()..update(updates))._build();

  _$Message._(
      {required this.id,
      required this.channelType,
      this.trackId,
      required this.senderRole,
      required this.content,
      required this.sentAt,
      this.readAt})
      : super._();
  @override
  Message rebuild(void Function(MessageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MessageBuilder toBuilder() => MessageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Message &&
        id == other.id &&
        channelType == other.channelType &&
        trackId == other.trackId &&
        senderRole == other.senderRole &&
        content == other.content &&
        sentAt == other.sentAt &&
        readAt == other.readAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, channelType.hashCode);
    _$hash = $jc(_$hash, trackId.hashCode);
    _$hash = $jc(_$hash, senderRole.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, sentAt.hashCode);
    _$hash = $jc(_$hash, readAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Message')
          ..add('id', id)
          ..add('channelType', channelType)
          ..add('trackId', trackId)
          ..add('senderRole', senderRole)
          ..add('content', content)
          ..add('sentAt', sentAt)
          ..add('readAt', readAt))
        .toString();
  }
}

class MessageBuilder implements Builder<Message, MessageBuilder> {
  _$Message? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  MessageChannelType? _channelType;
  MessageChannelType? get channelType => _$this._channelType;
  set channelType(MessageChannelType? channelType) =>
      _$this._channelType = channelType;

  String? _trackId;
  String? get trackId => _$this._trackId;
  set trackId(String? trackId) => _$this._trackId = trackId;

  MessageSenderRoleEnum? _senderRole;
  MessageSenderRoleEnum? get senderRole => _$this._senderRole;
  set senderRole(MessageSenderRoleEnum? senderRole) =>
      _$this._senderRole = senderRole;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  DateTime? _sentAt;
  DateTime? get sentAt => _$this._sentAt;
  set sentAt(DateTime? sentAt) => _$this._sentAt = sentAt;

  DateTime? _readAt;
  DateTime? get readAt => _$this._readAt;
  set readAt(DateTime? readAt) => _$this._readAt = readAt;

  MessageBuilder() {
    Message._defaults(this);
  }

  MessageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _channelType = $v.channelType;
      _trackId = $v.trackId;
      _senderRole = $v.senderRole;
      _content = $v.content;
      _sentAt = $v.sentAt;
      _readAt = $v.readAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Message other) {
    _$v = other as _$Message;
  }

  @override
  void update(void Function(MessageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Message build() => _build();

  _$Message _build() {
    final _$result = _$v ??
        _$Message._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Message', 'id'),
          channelType: BuiltValueNullFieldError.checkNotNull(
              channelType, r'Message', 'channelType'),
          trackId: trackId,
          senderRole: BuiltValueNullFieldError.checkNotNull(
              senderRole, r'Message', 'senderRole'),
          content: BuiltValueNullFieldError.checkNotNull(
              content, r'Message', 'content'),
          sentAt: BuiltValueNullFieldError.checkNotNull(
              sentAt, r'Message', 'sentAt'),
          readAt: readAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
