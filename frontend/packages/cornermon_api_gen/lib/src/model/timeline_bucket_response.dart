//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timeline_bucket_response.g.dart';

/// TimelineBucketResponse
///
/// Properties:
/// * [bucketStart] 
/// * [cumulativeCompleted] 
/// * [inProgressCount] 
@BuiltValue()
abstract class TimelineBucketResponse implements Built<TimelineBucketResponse, TimelineBucketResponseBuilder> {
  @BuiltValueField(wireName: r'bucketStart')
  DateTime? get bucketStart;

  @BuiltValueField(wireName: r'cumulativeCompleted')
  int? get cumulativeCompleted;

  @BuiltValueField(wireName: r'inProgressCount')
  int? get inProgressCount;

  TimelineBucketResponse._();

  factory TimelineBucketResponse([void updates(TimelineBucketResponseBuilder b)]) = _$TimelineBucketResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TimelineBucketResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TimelineBucketResponse> get serializer => _$TimelineBucketResponseSerializer();
}

class _$TimelineBucketResponseSerializer implements PrimitiveSerializer<TimelineBucketResponse> {
  @override
  final Iterable<Type> types = const [TimelineBucketResponse, _$TimelineBucketResponse];

  @override
  final String wireName = r'TimelineBucketResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TimelineBucketResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.bucketStart != null) {
      yield r'bucketStart';
      yield serializers.serialize(
        object.bucketStart,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.cumulativeCompleted != null) {
      yield r'cumulativeCompleted';
      yield serializers.serialize(
        object.cumulativeCompleted,
        specifiedType: const FullType(int),
      );
    }
    if (object.inProgressCount != null) {
      yield r'inProgressCount';
      yield serializers.serialize(
        object.inProgressCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TimelineBucketResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TimelineBucketResponseBuilder result,
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
        case r'cumulativeCompleted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.cumulativeCompleted = valueDes;
          break;
        case r'inProgressCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.inProgressCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TimelineBucketResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TimelineBucketResponseBuilder();
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

