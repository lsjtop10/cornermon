//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/corners_post_request_corners_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'corners_post_request.g.dart';

/// CornersPostRequest
///
/// Properties:
/// * [corners] 
@BuiltValue()
abstract class CornersPostRequest implements Built<CornersPostRequest, CornersPostRequestBuilder> {
  @BuiltValueField(wireName: r'corners')
  BuiltList<CornersPostRequestCornersInner> get corners;

  CornersPostRequest._();

  factory CornersPostRequest([void updates(CornersPostRequestBuilder b)]) = _$CornersPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CornersPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CornersPostRequest> get serializer => _$CornersPostRequestSerializer();
}

class _$CornersPostRequestSerializer implements PrimitiveSerializer<CornersPostRequest> {
  @override
  final Iterable<Type> types = const [CornersPostRequest, _$CornersPostRequest];

  @override
  final String wireName = r'CornersPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CornersPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'corners';
    yield serializers.serialize(
      object.corners,
      specifiedType: const FullType(BuiltList, [FullType(CornersPostRequestCornersInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CornersPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CornersPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'corners':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CornersPostRequestCornersInner)]),
          ) as BuiltList<CornersPostRequestCornersInner>;
          result.corners.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CornersPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CornersPostRequestBuilder();
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

