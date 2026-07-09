//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/message.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'messages_broadcast_get200_response.g.dart';

/// MessagesBroadcastGet200Response
///
/// Properties:
/// * [messages] 
@BuiltValue()
abstract class MessagesBroadcastGet200Response implements Built<MessagesBroadcastGet200Response, MessagesBroadcastGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'messages')
  BuiltList<Message>? get messages;

  MessagesBroadcastGet200Response._();

  factory MessagesBroadcastGet200Response([void updates(MessagesBroadcastGet200ResponseBuilder b)]) = _$MessagesBroadcastGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MessagesBroadcastGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MessagesBroadcastGet200Response> get serializer => _$MessagesBroadcastGet200ResponseSerializer();
}

class _$MessagesBroadcastGet200ResponseSerializer implements PrimitiveSerializer<MessagesBroadcastGet200Response> {
  @override
  final Iterable<Type> types = const [MessagesBroadcastGet200Response, _$MessagesBroadcastGet200Response];

  @override
  final String wireName = r'MessagesBroadcastGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MessagesBroadcastGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.messages != null) {
      yield r'messages';
      yield serializers.serialize(
        object.messages,
        specifiedType: const FullType(BuiltList, [FullType(Message)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MessagesBroadcastGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MessagesBroadcastGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'messages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Message)]),
          ) as BuiltList<Message>;
          result.messages.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MessagesBroadcastGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MessagesBroadcastGet200ResponseBuilder();
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

