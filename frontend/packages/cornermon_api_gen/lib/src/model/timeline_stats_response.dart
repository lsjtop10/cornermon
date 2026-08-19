//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/timeline_bucket_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timeline_stats_response.g.dart';

/// TimelineStatsResponse
///
/// Properties:
/// * [buckets] 
@BuiltValue()
abstract class TimelineStatsResponse implements Built<TimelineStatsResponse, TimelineStatsResponseBuilder> {
  @BuiltValueField(wireName: r'buckets')
  BuiltList<TimelineBucketResponse>? get buckets;

  TimelineStatsResponse._();

  factory TimelineStatsResponse([void updates(TimelineStatsResponseBuilder b)]) = _$TimelineStatsResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TimelineStatsResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TimelineStatsResponse> get serializer => _$TimelineStatsResponseSerializer();
}

class _$TimelineStatsResponseSerializer implements PrimitiveSerializer<TimelineStatsResponse> {
  @override
  final Iterable<Type> types = const [TimelineStatsResponse, _$TimelineStatsResponse];

  @override
  final String wireName = r'TimelineStatsResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TimelineStatsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.buckets != null) {
      yield r'buckets';
      yield serializers.serialize(
        object.buckets,
        specifiedType: const FullType(BuiltList, [FullType(TimelineBucketResponse)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TimelineStatsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TimelineStatsResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'buckets':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TimelineBucketResponse)]),
          ) as BuiltList<TimelineBucketResponse>;
          result.buckets.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TimelineStatsResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TimelineStatsResponseBuilder();
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

