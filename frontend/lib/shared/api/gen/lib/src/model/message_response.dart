//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'message_response.g.dart';

/// MessageResponse
///
/// Properties:
/// * [channelType] 
/// * [content] 
/// * [id] 
/// * [isRead] 
/// * [readAt] 
/// * [senderRole] 
/// * [sentAt] 
/// * [trackId] 
@BuiltValue()
abstract class MessageResponse implements Built<MessageResponse, MessageResponseBuilder> {
  @BuiltValueField(wireName: r'channelType')
  MessageResponseChannelTypeEnum? get channelType;
  // enum channelTypeEnum {  BROADCAST,  DIRECT,  };

  @BuiltValueField(wireName: r'content')
  String? get content;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'isRead')
  bool? get isRead;

  @BuiltValueField(wireName: r'readAt')
  DateTime? get readAt;

  @BuiltValueField(wireName: r'senderRole')
  MessageResponseSenderRoleEnum? get senderRole;
  // enum senderRoleEnum {  ADMIN,  TRACK,  };

  @BuiltValueField(wireName: r'sentAt')
  DateTime? get sentAt;

  @BuiltValueField(wireName: r'trackId')
  String? get trackId;

  MessageResponse._();

  factory MessageResponse([void updates(MessageResponseBuilder b)]) = _$MessageResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MessageResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MessageResponse> get serializer => _$MessageResponseSerializer();
}

class _$MessageResponseSerializer implements PrimitiveSerializer<MessageResponse> {
  @override
  final Iterable<Type> types = const [MessageResponse, _$MessageResponse];

  @override
  final String wireName = r'MessageResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MessageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.channelType != null) {
      yield r'channelType';
      yield serializers.serialize(
        object.channelType,
        specifiedType: const FullType(MessageResponseChannelTypeEnum),
      );
    }
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType(String),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.isRead != null) {
      yield r'isRead';
      yield serializers.serialize(
        object.isRead,
        specifiedType: const FullType(bool),
      );
    }
    if (object.readAt != null) {
      yield r'readAt';
      yield serializers.serialize(
        object.readAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.senderRole != null) {
      yield r'senderRole';
      yield serializers.serialize(
        object.senderRole,
        specifiedType: const FullType(MessageResponseSenderRoleEnum),
      );
    }
    if (object.sentAt != null) {
      yield r'sentAt';
      yield serializers.serialize(
        object.sentAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.trackId != null) {
      yield r'trackId';
      yield serializers.serialize(
        object.trackId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MessageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MessageResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'channelType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MessageResponseChannelTypeEnum),
          ) as MessageResponseChannelTypeEnum;
          result.channelType = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'isRead':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isRead = valueDes;
          break;
        case r'readAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.readAt = valueDes;
          break;
        case r'senderRole':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MessageResponseSenderRoleEnum),
          ) as MessageResponseSenderRoleEnum;
          result.senderRole = valueDes;
          break;
        case r'sentAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.sentAt = valueDes;
          break;
        case r'trackId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.trackId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MessageResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MessageResponseBuilder();
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

class MessageResponseChannelTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'BROADCAST')
  static const MessageResponseChannelTypeEnum BROADCAST = _$messageResponseChannelTypeEnum_BROADCAST;
  @BuiltValueEnumConst(wireName: r'DIRECT')
  static const MessageResponseChannelTypeEnum DIRECT = _$messageResponseChannelTypeEnum_DIRECT;

  static Serializer<MessageResponseChannelTypeEnum> get serializer => _$messageResponseChannelTypeEnumSerializer;

  const MessageResponseChannelTypeEnum._(String name): super(name);

  static BuiltSet<MessageResponseChannelTypeEnum> get values => _$messageResponseChannelTypeEnumValues;
  static MessageResponseChannelTypeEnum valueOf(String name) => _$messageResponseChannelTypeEnumValueOf(name);
}

class MessageResponseSenderRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const MessageResponseSenderRoleEnum ADMIN = _$messageResponseSenderRoleEnum_ADMIN;
  @BuiltValueEnumConst(wireName: r'TRACK')
  static const MessageResponseSenderRoleEnum TRACK = _$messageResponseSenderRoleEnum_TRACK;

  static Serializer<MessageResponseSenderRoleEnum> get serializer => _$messageResponseSenderRoleEnumSerializer;

  const MessageResponseSenderRoleEnum._(String name): super(name);

  static BuiltSet<MessageResponseSenderRoleEnum> get values => _$messageResponseSenderRoleEnumValues;
  static MessageResponseSenderRoleEnum valueOf(String name) => _$messageResponseSenderRoleEnumValueOf(name);
}

