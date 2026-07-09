//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/corner_stats_track_throughputs_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/corner_stats_unvisited_groups_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'corner_stats.g.dart';

/// CornerStats
///
/// Properties:
/// * [cornerId] 
/// * [cornerName] 
/// * [completedVisitCount] 
/// * [unvisitedGroups] 
/// * [avgDurationSeconds] 
/// * [medianDurationSeconds] 
/// * [stddevDurationSeconds] 
/// * [avgDeviationSeconds] 
/// * [positiveDeviationRatio] 
/// * [busyDurationSeconds] 
/// * [idleDurationSeconds] 
/// * [inactiveDurationSeconds] 
/// * [trackThroughputs] 
@BuiltValue()
abstract class CornerStats implements Built<CornerStats, CornerStatsBuilder> {
  @BuiltValueField(wireName: r'cornerId')
  String? get cornerId;

  @BuiltValueField(wireName: r'cornerName')
  String? get cornerName;

  @BuiltValueField(wireName: r'completedVisitCount')
  int? get completedVisitCount;

  @BuiltValueField(wireName: r'unvisitedGroups')
  BuiltList<CornerStatsUnvisitedGroupsInner>? get unvisitedGroups;

  @BuiltValueField(wireName: r'avgDurationSeconds')
  num? get avgDurationSeconds;

  @BuiltValueField(wireName: r'medianDurationSeconds')
  num? get medianDurationSeconds;

  @BuiltValueField(wireName: r'stddevDurationSeconds')
  num? get stddevDurationSeconds;

  @BuiltValueField(wireName: r'avgDeviationSeconds')
  num? get avgDeviationSeconds;

  @BuiltValueField(wireName: r'positiveDeviationRatio')
  double? get positiveDeviationRatio;

  @BuiltValueField(wireName: r'busyDurationSeconds')
  int? get busyDurationSeconds;

  @BuiltValueField(wireName: r'idleDurationSeconds')
  int? get idleDurationSeconds;

  @BuiltValueField(wireName: r'inactiveDurationSeconds')
  int? get inactiveDurationSeconds;

  @BuiltValueField(wireName: r'trackThroughputs')
  BuiltList<CornerStatsTrackThroughputsInner>? get trackThroughputs;

  CornerStats._();

  factory CornerStats([void updates(CornerStatsBuilder b)]) = _$CornerStats;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CornerStatsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CornerStats> get serializer => _$CornerStatsSerializer();
}

class _$CornerStatsSerializer implements PrimitiveSerializer<CornerStats> {
  @override
  final Iterable<Type> types = const [CornerStats, _$CornerStats];

  @override
  final String wireName = r'CornerStats';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CornerStats object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    if (object.completedVisitCount != null) {
      yield r'completedVisitCount';
      yield serializers.serialize(
        object.completedVisitCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.unvisitedGroups != null) {
      yield r'unvisitedGroups';
      yield serializers.serialize(
        object.unvisitedGroups,
        specifiedType: const FullType(BuiltList, [FullType(CornerStatsUnvisitedGroupsInner)]),
      );
    }
    if (object.avgDurationSeconds != null) {
      yield r'avgDurationSeconds';
      yield serializers.serialize(
        object.avgDurationSeconds,
        specifiedType: const FullType(num),
      );
    }
    if (object.medianDurationSeconds != null) {
      yield r'medianDurationSeconds';
      yield serializers.serialize(
        object.medianDurationSeconds,
        specifiedType: const FullType(num),
      );
    }
    if (object.stddevDurationSeconds != null) {
      yield r'stddevDurationSeconds';
      yield serializers.serialize(
        object.stddevDurationSeconds,
        specifiedType: const FullType(num),
      );
    }
    if (object.avgDeviationSeconds != null) {
      yield r'avgDeviationSeconds';
      yield serializers.serialize(
        object.avgDeviationSeconds,
        specifiedType: const FullType(num),
      );
    }
    if (object.positiveDeviationRatio != null) {
      yield r'positiveDeviationRatio';
      yield serializers.serialize(
        object.positiveDeviationRatio,
        specifiedType: const FullType(double),
      );
    }
    if (object.busyDurationSeconds != null) {
      yield r'busyDurationSeconds';
      yield serializers.serialize(
        object.busyDurationSeconds,
        specifiedType: const FullType(int),
      );
    }
    if (object.idleDurationSeconds != null) {
      yield r'idleDurationSeconds';
      yield serializers.serialize(
        object.idleDurationSeconds,
        specifiedType: const FullType(int),
      );
    }
    if (object.inactiveDurationSeconds != null) {
      yield r'inactiveDurationSeconds';
      yield serializers.serialize(
        object.inactiveDurationSeconds,
        specifiedType: const FullType(int),
      );
    }
    if (object.trackThroughputs != null) {
      yield r'trackThroughputs';
      yield serializers.serialize(
        object.trackThroughputs,
        specifiedType: const FullType(BuiltList, [FullType(CornerStatsTrackThroughputsInner)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CornerStats object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CornerStatsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'completedVisitCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.completedVisitCount = valueDes;
          break;
        case r'unvisitedGroups':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CornerStatsUnvisitedGroupsInner)]),
          ) as BuiltList<CornerStatsUnvisitedGroupsInner>;
          result.unvisitedGroups.replace(valueDes);
          break;
        case r'avgDurationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.avgDurationSeconds = valueDes;
          break;
        case r'medianDurationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.medianDurationSeconds = valueDes;
          break;
        case r'stddevDurationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.stddevDurationSeconds = valueDes;
          break;
        case r'avgDeviationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.avgDeviationSeconds = valueDes;
          break;
        case r'positiveDeviationRatio':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.positiveDeviationRatio = valueDes;
          break;
        case r'busyDurationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.busyDurationSeconds = valueDes;
          break;
        case r'idleDurationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.idleDurationSeconds = valueDes;
          break;
        case r'inactiveDurationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.inactiveDurationSeconds = valueDes;
          break;
        case r'trackThroughputs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CornerStatsTrackThroughputsInner)]),
          ) as BuiltList<CornerStatsTrackThroughputsInner>;
          result.trackThroughputs.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CornerStats deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CornerStatsBuilder();
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

