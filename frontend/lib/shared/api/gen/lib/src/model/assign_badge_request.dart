// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'assign_badge_request.g.dart';

/// AssignBadgeRequest
///
/// Properties:
/// * [groupId] 
@BuiltValue()
abstract class AssignBadgeRequest implements Built<AssignBadgeRequest, AssignBadgeRequestBuilder> {
  @BuiltValueField(wireName: r'groupId')
  String? get groupId;

  AssignBadgeRequest._();

  factory AssignBadgeRequest([void updates(AssignBadgeRequestBuilder b)]) = _$AssignBadgeRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AssignBadgeRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AssignBadgeRequest> get serializer => _$AssignBadgeRequestSerializer();
}

class _$AssignBadgeRequestSerializer implements PrimitiveSerializer<AssignBadgeRequest> {
  @override
  final Iterable<Type> types = const [AssignBadgeRequest, _$AssignBadgeRequest];

  @override
  final String wireName = r'AssignBadgeRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AssignBadgeRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.groupId != null) {
      yield r'groupId';
      yield serializers.serialize(
        object.groupId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AssignBadgeRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AssignBadgeRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'groupId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.groupId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AssignBadgeRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AssignBadgeRequestBuilder();
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
