//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'badges_bulk_generate_post_request.g.dart';

/// BadgesBulkGeneratePostRequest
///
/// Properties:
/// * [count] - 생성할 배지 수
@BuiltValue()
abstract class BadgesBulkGeneratePostRequest implements Built<BadgesBulkGeneratePostRequest, BadgesBulkGeneratePostRequestBuilder> {
  /// 생성할 배지 수
  @BuiltValueField(wireName: r'count')
  int get count;

  BadgesBulkGeneratePostRequest._();

  factory BadgesBulkGeneratePostRequest([void updates(BadgesBulkGeneratePostRequestBuilder b)]) = _$BadgesBulkGeneratePostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BadgesBulkGeneratePostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BadgesBulkGeneratePostRequest> get serializer => _$BadgesBulkGeneratePostRequestSerializer();
}

class _$BadgesBulkGeneratePostRequestSerializer implements PrimitiveSerializer<BadgesBulkGeneratePostRequest> {
  @override
  final Iterable<Type> types = const [BadgesBulkGeneratePostRequest, _$BadgesBulkGeneratePostRequest];

  @override
  final String wireName = r'BadgesBulkGeneratePostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BadgesBulkGeneratePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'count';
    yield serializers.serialize(
      object.count,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BadgesBulkGeneratePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BadgesBulkGeneratePostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.count = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BadgesBulkGeneratePostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BadgesBulkGeneratePostRequestBuilder();
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

