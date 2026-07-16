// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/corner_progress_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'group_response.g.dart';

/// GroupResponse
///
/// Properties:
/// * [badgeId] 
/// * [id] 
/// * [isFinished] 
/// * [itinerary] 
/// * [name] 
/// * [status] 
@BuiltValue()
abstract class GroupResponse implements Built<GroupResponse, GroupResponseBuilder> {
  @BuiltValueField(wireName: r'badgeId')
  String? get badgeId;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'isFinished')
  bool? get isFinished;

  @BuiltValueField(wireName: r'itinerary')
  BuiltList<CornerProgressResponse>? get itinerary;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'status')
  GroupResponseStatusEnum? get status;
  // enum statusEnum {  IDLE_MOVING,  AT_CORNER,  FINISHED,  };

  GroupResponse._();

  factory GroupResponse([void updates(GroupResponseBuilder b)]) = _$GroupResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GroupResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GroupResponse> get serializer => _$GroupResponseSerializer();
}

class _$GroupResponseSerializer implements PrimitiveSerializer<GroupResponse> {
  @override
  final Iterable<Type> types = const [GroupResponse, _$GroupResponse];

  @override
  final String wireName = r'GroupResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GroupResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.badgeId != null) {
      yield r'badgeId';
      yield serializers.serialize(
        object.badgeId,
        specifiedType: const FullType(String),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.isFinished != null) {
      yield r'isFinished';
      yield serializers.serialize(
        object.isFinished,
        specifiedType: const FullType(bool),
      );
    }
    if (object.itinerary != null) {
      yield r'itinerary';
      yield serializers.serialize(
        object.itinerary,
        specifiedType: const FullType(BuiltList, [FullType(CornerProgressResponse)]),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GroupResponseStatusEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GroupResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GroupResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'badgeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.badgeId = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'isFinished':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isFinished = valueDes;
          break;
        case r'itinerary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CornerProgressResponse)]),
          ) as BuiltList<CornerProgressResponse>;
          result.itinerary.replace(valueDes);
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GroupResponseStatusEnum),
          ) as GroupResponseStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GroupResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GroupResponseBuilder();
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

class GroupResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'IDLE_MOVING')
  static const GroupResponseStatusEnum IDLE_MOVING = _$groupResponseStatusEnum_IDLE_MOVING;
  @BuiltValueEnumConst(wireName: r'AT_CORNER')
  static const GroupResponseStatusEnum AT_CORNER = _$groupResponseStatusEnum_AT_CORNER;
  @BuiltValueEnumConst(wireName: r'FINISHED')
  static const GroupResponseStatusEnum FINISHED = _$groupResponseStatusEnum_FINISHED;

  static Serializer<GroupResponseStatusEnum> get serializer => _$groupResponseStatusEnumSerializer;

  const GroupResponseStatusEnum._(String name): super(name);

  static BuiltSet<GroupResponseStatusEnum> get values => _$groupResponseStatusEnumValues;
  static GroupResponseStatusEnum valueOf(String name) => _$groupResponseStatusEnumValueOf(name);
}
