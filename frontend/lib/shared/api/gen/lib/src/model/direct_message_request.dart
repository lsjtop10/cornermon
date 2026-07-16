// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_message_request.g.dart';

/// DirectMessageRequest
///
/// Properties:
/// * [content] 
@BuiltValue()
abstract class DirectMessageRequest implements Built<DirectMessageRequest, DirectMessageRequestBuilder> {
  @BuiltValueField(wireName: r'content')
  String? get content;

  DirectMessageRequest._();

  factory DirectMessageRequest([void updates(DirectMessageRequestBuilder b)]) = _$DirectMessageRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectMessageRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectMessageRequest> get serializer => _$DirectMessageRequestSerializer();
}

class _$DirectMessageRequestSerializer implements PrimitiveSerializer<DirectMessageRequest> {
  @override
  final Iterable<Type> types = const [DirectMessageRequest, _$DirectMessageRequest];

  @override
  final String wireName = r'DirectMessageRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectMessageRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DirectMessageRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectMessageRequestBuilder result,
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
  DirectMessageRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectMessageRequestBuilder();
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
