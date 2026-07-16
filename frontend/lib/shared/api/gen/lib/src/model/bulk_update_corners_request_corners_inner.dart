// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bulk_update_corners_request_corners_inner.g.dart';

/// BulkUpdateCornersRequestCornersInner
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [targetMinutes] 
@BuiltValue()
abstract class BulkUpdateCornersRequestCornersInner implements Built<BulkUpdateCornersRequestCornersInner, BulkUpdateCornersRequestCornersInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'targetMinutes')
  int? get targetMinutes;

  BulkUpdateCornersRequestCornersInner._();

  factory BulkUpdateCornersRequestCornersInner([void updates(BulkUpdateCornersRequestCornersInnerBuilder b)]) = _$BulkUpdateCornersRequestCornersInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BulkUpdateCornersRequestCornersInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BulkUpdateCornersRequestCornersInner> get serializer => _$BulkUpdateCornersRequestCornersInnerSerializer();
}

class _$BulkUpdateCornersRequestCornersInnerSerializer implements PrimitiveSerializer<BulkUpdateCornersRequestCornersInner> {
  @override
  final Iterable<Type> types = const [BulkUpdateCornersRequestCornersInner, _$BulkUpdateCornersRequestCornersInner];

  @override
  final String wireName = r'BulkUpdateCornersRequestCornersInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BulkUpdateCornersRequestCornersInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.targetMinutes != null) {
      yield r'targetMinutes';
      yield serializers.serialize(
        object.targetMinutes,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BulkUpdateCornersRequestCornersInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BulkUpdateCornersRequestCornersInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
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
  BulkUpdateCornersRequestCornersInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BulkUpdateCornersRequestCornersInnerBuilder();
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

