//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bottleneck_ranking_response.g.dart';

/// BottleneckRankingResponse
///
/// Properties:
/// * [avgDeviationSeconds] 
/// * [cornerId] 
/// * [cornerName] 
@BuiltValue()
abstract class BottleneckRankingResponse implements Built<BottleneckRankingResponse, BottleneckRankingResponseBuilder> {
  @BuiltValueField(wireName: r'avgDeviationSeconds')
  num? get avgDeviationSeconds;

  @BuiltValueField(wireName: r'cornerId')
  String? get cornerId;

  @BuiltValueField(wireName: r'cornerName')
  String? get cornerName;

  BottleneckRankingResponse._();

  factory BottleneckRankingResponse([void updates(BottleneckRankingResponseBuilder b)]) = _$BottleneckRankingResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BottleneckRankingResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BottleneckRankingResponse> get serializer => _$BottleneckRankingResponseSerializer();
}

class _$BottleneckRankingResponseSerializer implements PrimitiveSerializer<BottleneckRankingResponse> {
  @override
  final Iterable<Type> types = const [BottleneckRankingResponse, _$BottleneckRankingResponse];

  @override
  final String wireName = r'BottleneckRankingResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BottleneckRankingResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.avgDeviationSeconds != null) {
      yield r'avgDeviationSeconds';
      yield serializers.serialize(
        object.avgDeviationSeconds,
        specifiedType: const FullType(num),
      );
    }
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
  }

  @override
  Object serialize(
    Serializers serializers,
    BottleneckRankingResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BottleneckRankingResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'avgDeviationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.avgDeviationSeconds = valueDes;
          break;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BottleneckRankingResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BottleneckRankingResponseBuilder();
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

