//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'corners_bulk_update_patch_request.g.dart';

/// CornersBulkUpdatePatchRequest
///
/// Properties:
/// * [cornerIds] 
/// * [targetMinutes] 
@BuiltValue()
abstract class CornersBulkUpdatePatchRequest implements Built<CornersBulkUpdatePatchRequest, CornersBulkUpdatePatchRequestBuilder> {
  @BuiltValueField(wireName: r'cornerIds')
  BuiltList<String> get cornerIds;

  @BuiltValueField(wireName: r'targetMinutes')
  int get targetMinutes;

  CornersBulkUpdatePatchRequest._();

  factory CornersBulkUpdatePatchRequest([void updates(CornersBulkUpdatePatchRequestBuilder b)]) = _$CornersBulkUpdatePatchRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CornersBulkUpdatePatchRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CornersBulkUpdatePatchRequest> get serializer => _$CornersBulkUpdatePatchRequestSerializer();
}

class _$CornersBulkUpdatePatchRequestSerializer implements PrimitiveSerializer<CornersBulkUpdatePatchRequest> {
  @override
  final Iterable<Type> types = const [CornersBulkUpdatePatchRequest, _$CornersBulkUpdatePatchRequest];

  @override
  final String wireName = r'CornersBulkUpdatePatchRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CornersBulkUpdatePatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'cornerIds';
    yield serializers.serialize(
      object.cornerIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'targetMinutes';
    yield serializers.serialize(
      object.targetMinutes,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CornersBulkUpdatePatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CornersBulkUpdatePatchRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'cornerIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.cornerIds.replace(valueDes);
          break;
        case r'targetMinutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.targetMinutes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CornersBulkUpdatePatchRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CornersBulkUpdatePatchRequestBuilder();
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

