//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'corner_stats_track_throughputs_inner.g.dart';

/// CornerStatsTrackThroughputsInner
///
/// Properties:
/// * [trackId] 
/// * [completedVisitCount] 
/// * [avgDurationSeconds] 
@BuiltValue()
abstract class CornerStatsTrackThroughputsInner implements Built<CornerStatsTrackThroughputsInner, CornerStatsTrackThroughputsInnerBuilder> {
  @BuiltValueField(wireName: r'trackId')
  String? get trackId;

  @BuiltValueField(wireName: r'completedVisitCount')
  int? get completedVisitCount;

  @BuiltValueField(wireName: r'avgDurationSeconds')
  num? get avgDurationSeconds;

  CornerStatsTrackThroughputsInner._();

  factory CornerStatsTrackThroughputsInner([void updates(CornerStatsTrackThroughputsInnerBuilder b)]) = _$CornerStatsTrackThroughputsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CornerStatsTrackThroughputsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CornerStatsTrackThroughputsInner> get serializer => _$CornerStatsTrackThroughputsInnerSerializer();
}

class _$CornerStatsTrackThroughputsInnerSerializer implements PrimitiveSerializer<CornerStatsTrackThroughputsInner> {
  @override
  final Iterable<Type> types = const [CornerStatsTrackThroughputsInner, _$CornerStatsTrackThroughputsInner];

  @override
  final String wireName = r'CornerStatsTrackThroughputsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CornerStatsTrackThroughputsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.trackId != null) {
      yield r'trackId';
      yield serializers.serialize(
        object.trackId,
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
    if (object.avgDurationSeconds != null) {
      yield r'avgDurationSeconds';
      yield serializers.serialize(
        object.avgDurationSeconds,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CornerStatsTrackThroughputsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CornerStatsTrackThroughputsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'trackId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.trackId = valueDes;
          break;
        case r'completedVisitCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.completedVisitCount = valueDes;
          break;
        case r'avgDurationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.avgDurationSeconds = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CornerStatsTrackThroughputsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CornerStatsTrackThroughputsInnerBuilder();
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

