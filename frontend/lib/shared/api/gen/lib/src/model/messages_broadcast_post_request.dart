//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'messages_broadcast_post_request.g.dart';

/// MessagesBroadcastPostRequest
///
/// Properties:
/// * [content] - 공지 내용
@BuiltValue()
abstract class MessagesBroadcastPostRequest implements Built<MessagesBroadcastPostRequest, MessagesBroadcastPostRequestBuilder> {
  /// 공지 내용
  @BuiltValueField(wireName: r'content')
  String get content;

  MessagesBroadcastPostRequest._();

  factory MessagesBroadcastPostRequest([void updates(MessagesBroadcastPostRequestBuilder b)]) = _$MessagesBroadcastPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MessagesBroadcastPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MessagesBroadcastPostRequest> get serializer => _$MessagesBroadcastPostRequestSerializer();
}

class _$MessagesBroadcastPostRequestSerializer implements PrimitiveSerializer<MessagesBroadcastPostRequest> {
  @override
  final Iterable<Type> types = const [MessagesBroadcastPostRequest, _$MessagesBroadcastPostRequest];

  @override
  final String wireName = r'MessagesBroadcastPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MessagesBroadcastPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MessagesBroadcastPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MessagesBroadcastPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MessagesBroadcastPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MessagesBroadcastPostRequestBuilder();
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

