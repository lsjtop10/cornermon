//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/visit_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'groups_id_visits_get200_response.g.dart';

/// GroupsIdVisitsGet200Response
///
/// Properties:
/// * [visits] 
@BuiltValue()
abstract class GroupsIdVisitsGet200Response implements Built<GroupsIdVisitsGet200Response, GroupsIdVisitsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'visits')
  BuiltList<VisitSummary>? get visits;

  GroupsIdVisitsGet200Response._();

  factory GroupsIdVisitsGet200Response([void updates(GroupsIdVisitsGet200ResponseBuilder b)]) = _$GroupsIdVisitsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GroupsIdVisitsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GroupsIdVisitsGet200Response> get serializer => _$GroupsIdVisitsGet200ResponseSerializer();
}

class _$GroupsIdVisitsGet200ResponseSerializer implements PrimitiveSerializer<GroupsIdVisitsGet200Response> {
  @override
  final Iterable<Type> types = const [GroupsIdVisitsGet200Response, _$GroupsIdVisitsGet200Response];

  @override
  final String wireName = r'GroupsIdVisitsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GroupsIdVisitsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.visits != null) {
      yield r'visits';
      yield serializers.serialize(
        object.visits,
        specifiedType: const FullType(BuiltList, [FullType(VisitSummary)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GroupsIdVisitsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GroupsIdVisitsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'visits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(VisitSummary)]),
          ) as BuiltList<VisitSummary>;
          result.visits.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GroupsIdVisitsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GroupsIdVisitsGet200ResponseBuilder();
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

