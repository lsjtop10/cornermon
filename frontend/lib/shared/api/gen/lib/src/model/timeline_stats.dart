//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/timeline_stats_in_progress_counts_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timeline_stats.g.dart';

/// TimelineStats
///
/// Properties:
/// * [bucketMinutes] - 시계열 버킷 크기 (분)
/// * [inProgressCounts] 
/// * [cumulativeCompletedCounts] 
@BuiltValue()
abstract class TimelineStats implements Built<TimelineStats, TimelineStatsBuilder> {
  /// 시계열 버킷 크기 (분)
  @BuiltValueField(wireName: r'bucketMinutes')
  int? get bucketMinutes;

  @BuiltValueField(wireName: r'inProgressCounts')
  BuiltList<TimelineStatsInProgressCountsInner>? get inProgressCounts;

  @BuiltValueField(wireName: r'cumulativeCompletedCounts')
  BuiltList<TimelineStatsInProgressCountsInner>? get cumulativeCompletedCounts;

  TimelineStats._();

  factory TimelineStats([void updates(TimelineStatsBuilder b)]) = _$TimelineStats;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TimelineStatsBuilder b) => b
      ..bucketMinutes = 5;

  @BuiltValueSerializer(custom: true)
  static Serializer<TimelineStats> get serializer => _$TimelineStatsSerializer();
}

class _$TimelineStatsSerializer implements PrimitiveSerializer<TimelineStats> {
  @override
  final Iterable<Type> types = const [TimelineStats, _$TimelineStats];

  @override
  final String wireName = r'TimelineStats';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TimelineStats object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.bucketMinutes != null) {
      yield r'bucketMinutes';
      yield serializers.serialize(
        object.bucketMinutes,
        specifiedType: const FullType(int),
      );
    }
    if (object.inProgressCounts != null) {
      yield r'inProgressCounts';
      yield serializers.serialize(
        object.inProgressCounts,
        specifiedType: const FullType(BuiltList, [FullType(TimelineStatsInProgressCountsInner)]),
      );
    }
    if (object.cumulativeCompletedCounts != null) {
      yield r'cumulativeCompletedCounts';
      yield serializers.serialize(
        object.cumulativeCompletedCounts,
        specifiedType: const FullType(BuiltList, [FullType(TimelineStatsInProgressCountsInner)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TimelineStats object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TimelineStatsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'bucketMinutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.bucketMinutes = valueDes;
          break;
        case r'inProgressCounts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TimelineStatsInProgressCountsInner)]),
          ) as BuiltList<TimelineStatsInProgressCountsInner>;
          result.inProgressCounts.replace(valueDes);
          break;
        case r'cumulativeCompletedCounts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TimelineStatsInProgressCountsInner)]),
          ) as BuiltList<TimelineStatsInProgressCountsInner>;
          result.cumulativeCompletedCounts.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TimelineStats deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TimelineStatsBuilder();
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

