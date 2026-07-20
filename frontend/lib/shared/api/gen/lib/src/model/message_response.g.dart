// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'message_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MessageResponseChannelTypeEnum
    _$messageResponseChannelTypeEnum_BROADCAST =
    const MessageResponseChannelTypeEnum._('BROADCAST');
const MessageResponseChannelTypeEnum _$messageResponseChannelTypeEnum_DIRECT =
    const MessageResponseChannelTypeEnum._('DIRECT');

MessageResponseChannelTypeEnum _$messageResponseChannelTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'BROADCAST':
      return _$messageResponseChannelTypeEnum_BROADCAST;
    case 'DIRECT':
      return _$messageResponseChannelTypeEnum_DIRECT;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MessageResponseChannelTypeEnum>
    _$messageResponseChannelTypeEnumValues = BuiltSet<
        MessageResponseChannelTypeEnum>(const <MessageResponseChannelTypeEnum>[
  _$messageResponseChannelTypeEnum_BROADCAST,
  _$messageResponseChannelTypeEnum_DIRECT,
]);

const MessageResponseSenderRoleEnum _$messageResponseSenderRoleEnum_ADMIN =
    const MessageResponseSenderRoleEnum._('ADMIN');
const MessageResponseSenderRoleEnum _$messageResponseSenderRoleEnum_TRACK =
    const MessageResponseSenderRoleEnum._('TRACK');

MessageResponseSenderRoleEnum _$messageResponseSenderRoleEnumValueOf(
    String name) {
  switch (name) {
    case 'ADMIN':
      return _$messageResponseSenderRoleEnum_ADMIN;
    case 'TRACK':
      return _$messageResponseSenderRoleEnum_TRACK;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MessageResponseSenderRoleEnum>
    _$messageResponseSenderRoleEnumValues = BuiltSet<
        MessageResponseSenderRoleEnum>(const <MessageResponseSenderRoleEnum>[
  _$messageResponseSenderRoleEnum_ADMIN,
  _$messageResponseSenderRoleEnum_TRACK,
]);

Serializer<MessageResponseChannelTypeEnum>
    _$messageResponseChannelTypeEnumSerializer =
    _$MessageResponseChannelTypeEnumSerializer();
Serializer<MessageResponseSenderRoleEnum>
    _$messageResponseSenderRoleEnumSerializer =
    _$MessageResponseSenderRoleEnumSerializer();

class _$MessageResponseChannelTypeEnumSerializer
    implements PrimitiveSerializer<MessageResponseChannelTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'BROADCAST': 'BROADCAST',
    'DIRECT': 'DIRECT',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'BROADCAST': 'BROADCAST',
    'DIRECT': 'DIRECT',
  };

  @override
  final Iterable<Type> types = const <Type>[MessageResponseChannelTypeEnum];
  @override
  final String wireName = 'MessageResponseChannelTypeEnum';

  @override
  Object serialize(
          Serializers serializers, MessageResponseChannelTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MessageResponseChannelTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MessageResponseChannelTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MessageResponseSenderRoleEnumSerializer
    implements PrimitiveSerializer<MessageResponseSenderRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ADMIN': 'ADMIN',
    'TRACK': 'TRACK',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ADMIN': 'ADMIN',
    'TRACK': 'TRACK',
  };

  @override
  final Iterable<Type> types = const <Type>[MessageResponseSenderRoleEnum];
  @override
  final String wireName = 'MessageResponseSenderRoleEnum';

  @override
  Object serialize(
          Serializers serializers, MessageResponseSenderRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MessageResponseSenderRoleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MessageResponseSenderRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MessageResponse extends MessageResponse {
  @override
  final MessageResponseChannelTypeEnum? channelType;
  @override
  final String? content;
  @override
  final String? id;
  @override
  final bool? isRead;
  @override
  final DateTime? readAt;
  @override
  final MessageResponseSenderRoleEnum? senderRole;
  @override
  final DateTime? sentAt;
  @override
  final String? trackId;

  factory _$MessageResponse([void Function(MessageResponseBuilder)? updates]) =>
      (MessageResponseBuilder()..update(updates))._build();

  _$MessageResponse._(
      {this.channelType,
      this.content,
      this.id,
      this.isRead,
      this.readAt,
      this.senderRole,
      this.sentAt,
      this.trackId})
      : super._();
  @override
  MessageResponse rebuild(void Function(MessageResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MessageResponseBuilder toBuilder() => MessageResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MessageResponse &&
        channelType == other.channelType &&
        content == other.content &&
        id == other.id &&
        isRead == other.isRead &&
        readAt == other.readAt &&
        senderRole == other.senderRole &&
        sentAt == other.sentAt &&
        trackId == other.trackId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, channelType.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, isRead.hashCode);
    _$hash = $jc(_$hash, readAt.hashCode);
    _$hash = $jc(_$hash, senderRole.hashCode);
    _$hash = $jc(_$hash, sentAt.hashCode);
    _$hash = $jc(_$hash, trackId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MessageResponse')
          ..add('channelType', channelType)
          ..add('content', content)
          ..add('id', id)
          ..add('isRead', isRead)
          ..add('readAt', readAt)
          ..add('senderRole', senderRole)
          ..add('sentAt', sentAt)
          ..add('trackId', trackId))
        .toString();
  }
}

class MessageResponseBuilder
    implements Builder<MessageResponse, MessageResponseBuilder> {
  _$MessageResponse? _$v;

  MessageResponseChannelTypeEnum? _channelType;
  MessageResponseChannelTypeEnum? get channelType => _$this._channelType;
  set channelType(MessageResponseChannelTypeEnum? channelType) =>
      _$this._channelType = channelType;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  bool? _isRead;
  bool? get isRead => _$this._isRead;
  set isRead(bool? isRead) => _$this._isRead = isRead;

  DateTime? _readAt;
  DateTime? get readAt => _$this._readAt;
  set readAt(DateTime? readAt) => _$this._readAt = readAt;

  MessageResponseSenderRoleEnum? _senderRole;
  MessageResponseSenderRoleEnum? get senderRole => _$this._senderRole;
  set senderRole(MessageResponseSenderRoleEnum? senderRole) =>
      _$this._senderRole = senderRole;

  DateTime? _sentAt;
  DateTime? get sentAt => _$this._sentAt;
  set sentAt(DateTime? sentAt) => _$this._sentAt = sentAt;

  String? _trackId;
  String? get trackId => _$this._trackId;
  set trackId(String? trackId) => _$this._trackId = trackId;

  MessageResponseBuilder() {
    MessageResponse._defaults(this);
  }

  MessageResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _channelType = $v.channelType;
      _content = $v.content;
      _id = $v.id;
      _isRead = $v.isRead;
      _readAt = $v.readAt;
      _senderRole = $v.senderRole;
      _sentAt = $v.sentAt;
      _trackId = $v.trackId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MessageResponse other) {
    _$v = other as _$MessageResponse;
  }

  @override
  void update(void Function(MessageResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MessageResponse build() => _build();

  _$MessageResponse _build() {
    final _$result = _$v ??
        _$MessageResponse._(
          channelType: channelType,
          content: content,
          id: id,
          isRead: isRead,
          readAt: readAt,
          senderRole: senderRole,
          sentAt: sentAt,
          trackId: trackId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
