// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'track_stats_response.g.dart';

/// TrackStatsResponse
///
/// Properties:
/// * [avgDeviationSeconds] 
/// * [handledVisitCount] 
/// * [manualVisitRatio] 
/// * [trackId] 
/// * [trackNo] 
@BuiltValue()
abstract class TrackStatsResponse implements Built<TrackStatsResponse, TrackStatsResponseBuilder> {
  @BuiltValueField(wireName: r'avgDeviationSeconds')
  int? get avgDeviationSeconds;

  @BuiltValueField(wireName: r'handledVisitCount')
  int? get handledVisitCount;

  @BuiltValueField(wireName: r'manualVisitRatio')
  num? get manualVisitRatio;

  @BuiltValueField(wireName: r'trackId')
  String? get trackId;

  @BuiltValueField(wireName: r'trackNo')
  int? get trackNo;

  TrackStatsResponse._();

  factory TrackStatsResponse([void updates(TrackStatsResponseBuilder b)]) = _$TrackStatsResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackStatsResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackStatsResponse> get serializer => _$TrackStatsResponseSerializer();
}

class _$TrackStatsResponseSerializer implements PrimitiveSerializer<TrackStatsResponse> {
  @override
  final Iterable<Type> types = const [TrackStatsResponse, _$TrackStatsResponse];

  @override
  final String wireName = r'TrackStatsResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackStatsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.avgDeviationSeconds != null) {
      yield r'avgDeviationSeconds';
      yield serializers.serialize(
        object.avgDeviationSeconds,
        specifiedType: const FullType(int),
      );
    }
    if (object.handledVisitCount != null) {
      yield r'handledVisitCount';
      yield serializers.serialize(
        object.handledVisitCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.manualVisitRatio != null) {
      yield r'manualVisitRatio';
      yield serializers.serialize(
        object.manualVisitRatio,
        specifiedType: const FullType(num),
      );
    }
    if (object.trackId != null) {
      yield r'trackId';
      yield serializers.serialize(
        object.trackId,
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
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackStatsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackStatsResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'avgDeviationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.avgDeviationSeconds = valueDes;
          break;
        case r'handledVisitCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.handledVisitCount = valueDes;
          break;
        case r'manualVisitRatio':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.manualVisitRatio = valueDes;
          break;
        case r'trackId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.trackId = valueDes;
          break;
        case r'trackNo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.trackNo = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackStatsResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackStatsResponseBuilder();
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
