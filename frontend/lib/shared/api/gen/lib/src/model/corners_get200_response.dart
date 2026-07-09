//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/corner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'corners_get200_response.g.dart';

/// CornersGet200Response
///
/// Properties:
/// * [corners] 
@BuiltValue()
abstract class CornersGet200Response implements Built<CornersGet200Response, CornersGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'corners')
  BuiltList<Corner>? get corners;

  CornersGet200Response._();

  factory CornersGet200Response([void updates(CornersGet200ResponseBuilder b)]) = _$CornersGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CornersGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CornersGet200Response> get serializer => _$CornersGet200ResponseSerializer();
}

class _$CornersGet200ResponseSerializer implements PrimitiveSerializer<CornersGet200Response> {
  @override
  final Iterable<Type> types = const [CornersGet200Response, _$CornersGet200Response];

  @override
  final String wireName = r'CornersGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CornersGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.corners != null) {
      yield r'corners';
      yield serializers.serialize(
        object.corners,
        specifiedType: const FullType(BuiltList, [FullType(Corner)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CornersGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CornersGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'corners':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Corner)]),
          ) as BuiltList<Corner>;
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
  CornersGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CornersGet200ResponseBuilder();
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

