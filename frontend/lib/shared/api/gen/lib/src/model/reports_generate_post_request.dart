//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reports_generate_post_request.g.dart';

/// ReportsGeneratePostRequest
///
/// Properties:
/// * [campId] 
@BuiltValue()
abstract class ReportsGeneratePostRequest implements Built<ReportsGeneratePostRequest, ReportsGeneratePostRequestBuilder> {
  @BuiltValueField(wireName: r'campId')
  String get campId;

  ReportsGeneratePostRequest._();

  factory ReportsGeneratePostRequest([void updates(ReportsGeneratePostRequestBuilder b)]) = _$ReportsGeneratePostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReportsGeneratePostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReportsGeneratePostRequest> get serializer => _$ReportsGeneratePostRequestSerializer();
}

class _$ReportsGeneratePostRequestSerializer implements PrimitiveSerializer<ReportsGeneratePostRequest> {
  @override
  final Iterable<Type> types = const [ReportsGeneratePostRequest, _$ReportsGeneratePostRequest];

  @override
  final String wireName = r'ReportsGeneratePostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReportsGeneratePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'campId';
    yield serializers.serialize(
      object.campId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReportsGeneratePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReportsGeneratePostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'campId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.campId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReportsGeneratePostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReportsGeneratePostRequestBuilder();
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

