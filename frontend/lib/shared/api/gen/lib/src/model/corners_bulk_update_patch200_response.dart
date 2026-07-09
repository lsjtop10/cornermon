//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'corners_bulk_update_patch200_response.g.dart';

/// CornersBulkUpdatePatch200Response
///
/// Properties:
/// * [updatedCount] 
@BuiltValue()
abstract class CornersBulkUpdatePatch200Response implements Built<CornersBulkUpdatePatch200Response, CornersBulkUpdatePatch200ResponseBuilder> {
  @BuiltValueField(wireName: r'updatedCount')
  int? get updatedCount;

  CornersBulkUpdatePatch200Response._();

  factory CornersBulkUpdatePatch200Response([void updates(CornersBulkUpdatePatch200ResponseBuilder b)]) = _$CornersBulkUpdatePatch200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CornersBulkUpdatePatch200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CornersBulkUpdatePatch200Response> get serializer => _$CornersBulkUpdatePatch200ResponseSerializer();
}

class _$CornersBulkUpdatePatch200ResponseSerializer implements PrimitiveSerializer<CornersBulkUpdatePatch200Response> {
  @override
  final Iterable<Type> types = const [CornersBulkUpdatePatch200Response, _$CornersBulkUpdatePatch200Response];

  @override
  final String wireName = r'CornersBulkUpdatePatch200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CornersBulkUpdatePatch200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.updatedCount != null) {
      yield r'updatedCount';
      yield serializers.serialize(
        object.updatedCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CornersBulkUpdatePatch200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CornersBulkUpdatePatch200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'updatedCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.updatedCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CornersBulkUpdatePatch200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CornersBulkUpdatePatch200ResponseBuilder();
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

