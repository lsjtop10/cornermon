//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/message_channel_type.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'message.g.dart';

/// Message
///
/// Properties:
/// * [id] 
/// * [channelType] 
/// * [trackId] - DIRECT 채널인 경우 대상 트랙 ID
/// * [senderRole] 
/// * [content] 
/// * [sentAt] 
/// * [readAt] 
@BuiltValue()
abstract class Message implements Built<Message, MessageBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'channelType')
  MessageChannelType get channelType;
  // enum channelTypeEnum {  BROADCAST,  DIRECT,  };

  /// DIRECT 채널인 경우 대상 트랙 ID
  @BuiltValueField(wireName: r'trackId')
  String? get trackId;

  @BuiltValueField(wireName: r'senderRole')
  MessageSenderRoleEnum get senderRole;
  // enum senderRoleEnum {  ADMIN,  TRACK,  };

  @BuiltValueField(wireName: r'content')
  String get content;

  @BuiltValueField(wireName: r'sentAt')
  DateTime get sentAt;

  @BuiltValueField(wireName: r'readAt')
  DateTime? get readAt;

  Message._();

  factory Message([void updates(MessageBuilder b)]) = _$Message;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MessageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Message> get serializer => _$MessageSerializer();
}

class _$MessageSerializer implements PrimitiveSerializer<Message> {
  @override
  final Iterable<Type> types = const [Message, _$Message];

  @override
  final String wireName = r'Message';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Message object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'channelType';
    yield serializers.serialize(
      object.channelType,
      specifiedType: const FullType(MessageChannelType),
    );
    if (object.trackId != null) {
      yield r'trackId';
      yield serializers.serialize(
        object.trackId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'senderRole';
    yield serializers.serialize(
      object.senderRole,
      specifiedType: const FullType(MessageSenderRoleEnum),
    );
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    yield r'sentAt';
    yield serializers.serialize(
      object.sentAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.readAt != null) {
      yield r'readAt';
      yield serializers.serialize(
        object.readAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Message object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MessageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'channelType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MessageChannelType),
          ) as MessageChannelType;
          result.channelType = valueDes;
          break;
        case r'trackId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.trackId = valueDes;
          break;
        case r'senderRole':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MessageSenderRoleEnum),
          ) as MessageSenderRoleEnum;
          result.senderRole = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'sentAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.sentAt = valueDes;
          break;
        case r'readAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.readAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Message deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MessageBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class MessageSenderRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const MessageSenderRoleEnum ADMIN = _$messageSenderRoleEnum_ADMIN;
  @BuiltValueEnumConst(wireName: r'TRACK')
  static const MessageSenderRoleEnum TRACK = _$messageSenderRoleEnum_TRACK;

  static Serializer<MessageSenderRoleEnum> get serializer => _$messageSenderRoleEnumSerializer;

  const MessageSenderRoleEnum._(String name): super(name);

  static BuiltSet<MessageSenderRoleEnum> get values => _$messageSenderRoleEnumValues;
  static MessageSenderRoleEnum valueOf(String name) => _$messageSenderRoleEnumValueOf(name);
}

