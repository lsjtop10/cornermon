//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/group_stats_corner_durations_inner.dart';
import 'package:cornermon_api_gen/src/model/group_stats_unvisited_corners_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'group_stats.g.dart';

/// GroupStats
///
/// Properties:
/// * [groupId] 
/// * [groupName] 
/// * [isFinished] 
/// * [completedCornerCount] 
/// * [totalActivitySeconds] 
/// * [cornerDurations] 
/// * [unvisitedCorners] 
@BuiltValue()
abstract class GroupStats implements Built<GroupStats, GroupStatsBuilder> {
  @BuiltValueField(wireName: r'groupId')
  String? get groupId;

  @BuiltValueField(wireName: r'groupName')
  String? get groupName;

  @BuiltValueField(wireName: r'isFinished')
  bool? get isFinished;

  @BuiltValueField(wireName: r'completedCornerCount')
  int? get completedCornerCount;

  @BuiltValueField(wireName: r'totalActivitySeconds')
  int? get totalActivitySeconds;

  @BuiltValueField(wireName: r'cornerDurations')
  BuiltList<GroupStatsCornerDurationsInner>? get cornerDurations;

  @BuiltValueField(wireName: r'unvisitedCorners')
  BuiltList<GroupStatsUnvisitedCornersInner>? get unvisitedCorners;

  GroupStats._();

  factory GroupStats([void updates(GroupStatsBuilder b)]) = _$GroupStats;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GroupStatsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GroupStats> get serializer => _$GroupStatsSerializer();
}

class _$GroupStatsSerializer implements PrimitiveSerializer<GroupStats> {
  @override
  final Iterable<Type> types = const [GroupStats, _$GroupStats];

  @override
  final String wireName = r'GroupStats';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GroupStats object, {
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
    if (object.isFinished != null) {
      yield r'isFinished';
      yield serializers.serialize(
        object.isFinished,
        specifiedType: const FullType(bool),
      );
    }
    if (object.completedCornerCount != null) {
      yield r'completedCornerCount';
      yield serializers.serialize(
        object.completedCornerCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.totalActivitySeconds != null) {
      yield r'totalActivitySeconds';
      yield serializers.serialize(
        object.totalActivitySeconds,
        specifiedType: const FullType(int),
      );
    }
    if (object.cornerDurations != null) {
      yield r'cornerDurations';
      yield serializers.serialize(
        object.cornerDurations,
        specifiedType: const FullType(BuiltList, [FullType(GroupStatsCornerDurationsInner)]),
      );
    }
    if (object.unvisitedCorners != null) {
      yield r'unvisitedCorners';
      yield serializers.serialize(
        object.unvisitedCorners,
        specifiedType: const FullType(BuiltList, [FullType(GroupStatsUnvisitedCornersInner)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GroupStats object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GroupStatsBuilder result,
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
        case r'isFinished':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isFinished = valueDes;
          break;
        case r'completedCornerCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.completedCornerCount = valueDes;
          break;
        case r'totalActivitySeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalActivitySeconds = valueDes;
          break;
        case r'cornerDurations':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(GroupStatsCornerDurationsInner)]),
          ) as BuiltList<GroupStatsCornerDurationsInner>;
          result.cornerDurations.replace(valueDes);
          break;
        case r'unvisitedCorners':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(GroupStatsUnvisitedCornersInner)]),
          ) as BuiltList<GroupStatsUnvisitedCornersInner>;
          result.unvisitedCorners.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GroupStats deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GroupStatsBuilder();
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

