//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timeline_stats_in_progress_counts_inner.g.dart';

/// TimelineStatsInProgressCountsInner
///
/// Properties:
/// * [bucketStart] 
/// * [count] 
@BuiltValue()
abstract class TimelineStatsInProgressCountsInner implements Built<TimelineStatsInProgressCountsInner, TimelineStatsInProgressCountsInnerBuilder> {
  @BuiltValueField(wireName: r'bucketStart')
  DateTime? get bucketStart;

  @BuiltValueField(wireName: r'count')
  int? get count;

  TimelineStatsInProgressCountsInner._();

  factory TimelineStatsInProgressCountsInner([void updates(TimelineStatsInProgressCountsInnerBuilder b)]) = _$TimelineStatsInProgressCountsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TimelineStatsInProgressCountsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TimelineStatsInProgressCountsInner> get serializer => _$TimelineStatsInProgressCountsInnerSerializer();
}

class _$TimelineStatsInProgressCountsInnerSerializer implements PrimitiveSerializer<TimelineStatsInProgressCountsInner> {
  @override
  final Iterable<Type> types = const [TimelineStatsInProgressCountsInner, _$TimelineStatsInProgressCountsInner];

  @override
  final String wireName = r'TimelineStatsInProgressCountsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TimelineStatsInProgressCountsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.bucketStart != null) {
      yield r'bucketStart';
      yield serializers.serialize(
        object.bucketStart,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.count != null) {
      yield r'count';
      yield serializers.serialize(
        object.count,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TimelineStatsInProgressCountsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TimelineStatsInProgressCountsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'bucketStart':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.bucketStart = valueDes;
          break;
        case r'count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.count = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TimelineStatsInProgressCountsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TimelineStatsInProgressCountsInnerBuilder();
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

