//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'track_stats.g.dart';

/// TrackStats
///
/// Properties:
/// * [trackId] 
/// * [cornerId] 
/// * [trackNo] 
/// * [lifecycleStart] 
/// * [lifecycleEnd] - 삭제된 경우 삭제 시각, 캠프 종료까지 살아있었으면 종료 시각
/// * [completedVisitCount] 
/// * [avgDurationSeconds] 
/// * [pinLoginFailureCount] 
@BuiltValue()
abstract class TrackStats implements Built<TrackStats, TrackStatsBuilder> {
  @BuiltValueField(wireName: r'trackId')
  String? get trackId;

  @BuiltValueField(wireName: r'cornerId')
  String? get cornerId;

  @BuiltValueField(wireName: r'trackNo')
  int? get trackNo;

  @BuiltValueField(wireName: r'lifecycleStart')
  DateTime? get lifecycleStart;

  /// 삭제된 경우 삭제 시각, 캠프 종료까지 살아있었으면 종료 시각
  @BuiltValueField(wireName: r'lifecycleEnd')
  DateTime? get lifecycleEnd;

  @BuiltValueField(wireName: r'completedVisitCount')
  int? get completedVisitCount;

  @BuiltValueField(wireName: r'avgDurationSeconds')
  num? get avgDurationSeconds;

  @BuiltValueField(wireName: r'pinLoginFailureCount')
  int? get pinLoginFailureCount;

  TrackStats._();

  factory TrackStats([void updates(TrackStatsBuilder b)]) = _$TrackStats;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackStatsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackStats> get serializer => _$TrackStatsSerializer();
}

class _$TrackStatsSerializer implements PrimitiveSerializer<TrackStats> {
  @override
  final Iterable<Type> types = const [TrackStats, _$TrackStats];

  @override
  final String wireName = r'TrackStats';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackStats object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.trackId != null) {
      yield r'trackId';
      yield serializers.serialize(
        object.trackId,
        specifiedType: const FullType(String),
      );
    }
    if (object.cornerId != null) {
      yield r'cornerId';
      yield serializers.serialize(
        object.cornerId,
        specifiedType: const FullType(String),
      );
    }
    if (object.trackNo != null) {
      yield r'trackNo';
      yield serializers.serialize(
        object.trackNo,
        specifiedType: const FullType(int),
      );
    }
    if (object.lifecycleStart != null) {
      yield r'lifecycleStart';
      yield serializers.serialize(
        object.lifecycleStart,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.lifecycleEnd != null) {
      yield r'lifecycleEnd';
      yield serializers.serialize(
        object.lifecycleEnd,
        specifiedType: const FullType.nullable(DateTime),
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
    if (object.pinLoginFailureCount != null) {
      yield r'pinLoginFailureCount';
      yield serializers.serialize(
        object.pinLoginFailureCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackStats object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackStatsBuilder result,
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
        case r'cornerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cornerId = valueDes;
          break;
        case r'trackNo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.trackNo = valueDes;
          break;
        case r'lifecycleStart':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.lifecycleStart = valueDes;
          break;
        case r'lifecycleEnd':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lifecycleEnd = valueDes;
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
        case r'pinLoginFailureCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pinLoginFailureCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackStats deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackStatsBuilder();
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

