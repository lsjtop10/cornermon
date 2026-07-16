// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/bulk_update_corners_request_corners_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bulk_update_corners_request.g.dart';

/// BulkUpdateCornersRequest
///
/// Properties:
/// * [corners] 
@BuiltValue()
abstract class BulkUpdateCornersRequest implements Built<BulkUpdateCornersRequest, BulkUpdateCornersRequestBuilder> {
  @BuiltValueField(wireName: r'corners')
  BuiltList<BulkUpdateCornersRequestCornersInner>? get corners;

  BulkUpdateCornersRequest._();

  factory BulkUpdateCornersRequest([void updates(BulkUpdateCornersRequestBuilder b)]) = _$BulkUpdateCornersRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BulkUpdateCornersRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BulkUpdateCornersRequest> get serializer => _$BulkUpdateCornersRequestSerializer();
}

class _$BulkUpdateCornersRequestSerializer implements PrimitiveSerializer<BulkUpdateCornersRequest> {
  @override
  final Iterable<Type> types = const [BulkUpdateCornersRequest, _$BulkUpdateCornersRequest];

  @override
  final String wireName = r'BulkUpdateCornersRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BulkUpdateCornersRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.corners != null) {
      yield r'corners';
      yield serializers.serialize(
        object.corners,
        specifiedType: const FullType(BuiltList, [FullType(BulkUpdateCornersRequestCornersInner)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BulkUpdateCornersRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BulkUpdateCornersRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'corners':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BulkUpdateCornersRequestCornersInner)]),
          ) as BuiltList<BulkUpdateCornersRequestCornersInner>;
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
  BulkUpdateCornersRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BulkUpdateCornersRequestBuilder();
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

