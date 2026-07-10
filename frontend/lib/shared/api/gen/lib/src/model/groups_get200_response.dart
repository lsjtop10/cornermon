//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/group.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'groups_get200_response.g.dart';

/// GroupsGet200Response
///
/// Properties:
/// * [groups] 
@BuiltValue()
abstract class GroupsGet200Response implements Built<GroupsGet200Response, GroupsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'groups')
  BuiltList<Group>? get groups;

  GroupsGet200Response._();

  factory GroupsGet200Response([void updates(GroupsGet200ResponseBuilder b)]) = _$GroupsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GroupsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GroupsGet200Response> get serializer => _$GroupsGet200ResponseSerializer();
}

class _$GroupsGet200ResponseSerializer implements PrimitiveSerializer<GroupsGet200Response> {
  @override
  final Iterable<Type> types = const [GroupsGet200Response, _$GroupsGet200Response];

  @override
  final String wireName = r'GroupsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GroupsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.groups != null) {
      yield r'groups';
      yield serializers.serialize(
        object.groups,
        specifiedType: const FullType(BuiltList, [FullType(Group)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GroupsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GroupsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'groups':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Group)]),
          ) as BuiltList<Group>;
          result.groups.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GroupsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GroupsGet200ResponseBuilder();
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

