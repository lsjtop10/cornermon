// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/unvisited_group_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'corner_stats_response.g.dart';

/// CornerStatsResponse
///
/// Properties:
/// * [avgDeviationSeconds]
/// * [avgDurationSeconds]
/// * [completedVisitCount] 
/// * [cornerId] 
/// * [cornerName] 
/// * [overDeviationRatio] 
/// * [unvisitedGroups] 
@BuiltValue()
abstract class CornerStatsResponse implements Built<CornerStatsResponse, CornerStatsResponseBuilder> {
  @BuiltValueField(wireName: r'avgDeviationSeconds')
  num? get avgDeviationSeconds;

  @BuiltValueField(wireName: r'avgDurationSeconds')
  num? get avgDurationSeconds;

  @BuiltValueField(wireName: r'completedVisitCount')
  int? get completedVisitCount;

  @BuiltValueField(wireName: r'cornerId')
  String? get cornerId;

  @BuiltValueField(wireName: r'cornerName')
  String? get cornerName;

  @BuiltValueField(wireName: r'overDeviationRatio')
  num? get overDeviationRatio;

  @BuiltValueField(wireName: r'unvisitedGroups')
  BuiltList<UnvisitedGroupResponse>? get unvisitedGroups;

  CornerStatsResponse._();

  factory CornerStatsResponse([void updates(CornerStatsResponseBuilder b)]) = _$CornerStatsResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CornerStatsResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CornerStatsResponse> get serializer => _$CornerStatsResponseSerializer();
}

class _$CornerStatsResponseSerializer implements PrimitiveSerializer<CornerStatsResponse> {
  @override
  final Iterable<Type> types = const [CornerStatsResponse, _$CornerStatsResponse];

  @override
  final String wireName = r'CornerStatsResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CornerStatsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.avgDeviationSeconds != null) {
      yield r'avgDeviationSeconds';
      yield serializers.serialize(
        object.avgDeviationSeconds,
        specifiedType: const FullType(num),
      );
    }
    if (object.avgDurationSeconds != null) {
      yield r'avgDurationSeconds';
      yield serializers.serialize(
        object.avgDurationSeconds,
        specifiedType: const FullType(num),
      );
    }
    if (object.completedVisitCount != null) {
      yield r'completedVisitCount';
      yield serializers.serialize(
        object.completedVisitCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.cornerId != null) {
      yield r'cornerId';
      yield serializers.serialize(
        object.cornerId,
        specifiedType: const FullType(String),
      );
    }
    if (object.cornerName != null) {
      yield r'cornerName';
      yield serializers.serialize(
        object.cornerName,
        specifiedType: const FullType(String),
      );
    }
    if (object.overDeviationRatio != null) {
      yield r'overDeviationRatio';
      yield serializers.serialize(
        object.overDeviationRatio,
        specifiedType: const FullType(num),
      );
    }
    if (object.unvisitedGroups != null) {
      yield r'unvisitedGroups';
      yield serializers.serialize(
        object.unvisitedGroups,
        specifiedType: const FullType(BuiltList, [FullType(UnvisitedGroupResponse)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CornerStatsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CornerStatsResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'avgDeviationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.avgDeviationSeconds = valueDes;
          break;
        case r'avgDurationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.avgDurationSeconds = valueDes;
          break;
        case r'completedVisitCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.completedVisitCount = valueDes;
          break;
        case r'cornerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cornerId = valueDes;
          break;
        case r'cornerName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cornerName = valueDes;
          break;
        case r'overDeviationRatio':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.overDeviationRatio = valueDes;
          break;
        case r'unvisitedGroups':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(UnvisitedGroupResponse)]),
          ) as BuiltList<UnvisitedGroupResponse>;
          result.unvisitedGroups.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CornerStatsResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CornerStatsResponseBuilder();
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
