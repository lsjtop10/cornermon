//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/camp.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'camps_get200_response.g.dart';

/// CampsGet200Response
///
/// Properties:
/// * [camps] 
@BuiltValue()
abstract class CampsGet200Response implements Built<CampsGet200Response, CampsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'camps')
  BuiltList<Camp>? get camps;

  CampsGet200Response._();

  factory CampsGet200Response([void updates(CampsGet200ResponseBuilder b)]) = _$CampsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CampsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CampsGet200Response> get serializer => _$CampsGet200ResponseSerializer();
}

class _$CampsGet200ResponseSerializer implements PrimitiveSerializer<CampsGet200Response> {
  @override
  final Iterable<Type> types = const [CampsGet200Response, _$CampsGet200Response];

  @override
  final String wireName = r'CampsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CampsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.camps != null) {
      yield r'camps';
      yield serializers.serialize(
        object.camps,
        specifiedType: const FullType(BuiltList, [FullType(Camp)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CampsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CampsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'camps':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Camp)]),
          ) as BuiltList<Camp>;
          result.camps.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CampsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CampsGet200ResponseBuilder();
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

