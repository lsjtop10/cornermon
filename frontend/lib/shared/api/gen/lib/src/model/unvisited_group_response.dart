//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'unvisited_group_response.g.dart';

/// UnvisitedGroupResponse
///
/// Properties:
/// * [groupId] 
/// * [groupName] 
@BuiltValue()
abstract class UnvisitedGroupResponse implements Built<UnvisitedGroupResponse, UnvisitedGroupResponseBuilder> {
  @BuiltValueField(wireName: r'groupId')
  String? get groupId;

  @BuiltValueField(wireName: r'groupName')
  String? get groupName;

  UnvisitedGroupResponse._();

  factory UnvisitedGroupResponse([void updates(UnvisitedGroupResponseBuilder b)]) = _$UnvisitedGroupResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UnvisitedGroupResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UnvisitedGroupResponse> get serializer => _$UnvisitedGroupResponseSerializer();
}

class _$UnvisitedGroupResponseSerializer implements PrimitiveSerializer<UnvisitedGroupResponse> {
  @override
  final Iterable<Type> types = const [UnvisitedGroupResponse, _$UnvisitedGroupResponse];

  @override
  final String wireName = r'UnvisitedGroupResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UnvisitedGroupResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.groupId != null) {
      yield r'groupId';
      yield serializers.serialize(
        object.groupId,
        specifiedType: const FullType(String),
      );
    }
    if (object.groupName != null) {
      yield r'groupName';
      yield serializers.serialize(
        object.groupName,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UnvisitedGroupResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UnvisitedGroupResponseBuilder result,
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
        case r'groupName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.groupName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UnvisitedGroupResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UnvisitedGroupResponseBuilder();
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

