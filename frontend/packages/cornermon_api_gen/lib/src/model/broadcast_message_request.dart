//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'broadcast_message_request.g.dart';

/// BroadcastMessageRequest
///
/// Properties:
/// * [content] 
@BuiltValue()
abstract class BroadcastMessageRequest implements Built<BroadcastMessageRequest, BroadcastMessageRequestBuilder> {
  @BuiltValueField(wireName: r'content')
  String? get content;

  BroadcastMessageRequest._();

  factory BroadcastMessageRequest([void updates(BroadcastMessageRequestBuilder b)]) = _$BroadcastMessageRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BroadcastMessageRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BroadcastMessageRequest> get serializer => _$BroadcastMessageRequestSerializer();
}

class _$BroadcastMessageRequestSerializer implements PrimitiveSerializer<BroadcastMessageRequest> {
  @override
  final Iterable<Type> types = const [BroadcastMessageRequest, _$BroadcastMessageRequest];

  @override
  final String wireName = r'BroadcastMessageRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BroadcastMessageRequest object, {
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
    BroadcastMessageRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BroadcastMessageRequestBuilder result,
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
  BroadcastMessageRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BroadcastMessageRequestBuilder();
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

