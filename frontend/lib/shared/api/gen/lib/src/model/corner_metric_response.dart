// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'corner_metric_response.g.dart';

/// CornerMetricResponse
///
/// Properties:
/// * [avgDurationSeconds] 
/// * [sampleCount] 
@BuiltValue()
abstract class CornerMetricResponse implements Built<CornerMetricResponse, CornerMetricResponseBuilder> {
  @BuiltValueField(wireName: r'avgDurationSeconds')
  int? get avgDurationSeconds;

  @BuiltValueField(wireName: r'sampleCount')
  int? get sampleCount;

  CornerMetricResponse._();

  factory CornerMetricResponse([void updates(CornerMetricResponseBuilder b)]) = _$CornerMetricResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CornerMetricResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CornerMetricResponse> get serializer => _$CornerMetricResponseSerializer();
}

class _$CornerMetricResponseSerializer implements PrimitiveSerializer<CornerMetricResponse> {
  @override
  final Iterable<Type> types = const [CornerMetricResponse, _$CornerMetricResponse];

  @override
  final String wireName = r'CornerMetricResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CornerMetricResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.avgDurationSeconds != null) {
      yield r'avgDurationSeconds';
      yield serializers.serialize(
        object.avgDurationSeconds,
        specifiedType: const FullType(int),
      );
    }
    if (object.sampleCount != null) {
      yield r'sampleCount';
      yield serializers.serialize(
        object.sampleCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CornerMetricResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CornerMetricResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'avgDurationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.avgDurationSeconds = valueDes;
          break;
        case r'sampleCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sampleCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CornerMetricResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CornerMetricResponseBuilder();
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

