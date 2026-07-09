//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'camp_summary_stats_bottleneck_ranking_inner.g.dart';

/// CampSummaryStatsBottleneckRankingInner
///
/// Properties:
/// * [cornerId] 
/// * [cornerName] 
/// * [avgDeviationSeconds] 
@BuiltValue()
abstract class CampSummaryStatsBottleneckRankingInner implements Built<CampSummaryStatsBottleneckRankingInner, CampSummaryStatsBottleneckRankingInnerBuilder> {
  @BuiltValueField(wireName: r'cornerId')
  String? get cornerId;

  @BuiltValueField(wireName: r'cornerName')
  String? get cornerName;

  @BuiltValueField(wireName: r'avgDeviationSeconds')
  num? get avgDeviationSeconds;

  CampSummaryStatsBottleneckRankingInner._();

  factory CampSummaryStatsBottleneckRankingInner([void updates(CampSummaryStatsBottleneckRankingInnerBuilder b)]) = _$CampSummaryStatsBottleneckRankingInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CampSummaryStatsBottleneckRankingInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CampSummaryStatsBottleneckRankingInner> get serializer => _$CampSummaryStatsBottleneckRankingInnerSerializer();
}

class _$CampSummaryStatsBottleneckRankingInnerSerializer implements PrimitiveSerializer<CampSummaryStatsBottleneckRankingInner> {
  @override
  final Iterable<Type> types = const [CampSummaryStatsBottleneckRankingInner, _$CampSummaryStatsBottleneckRankingInner];

  @override
  final String wireName = r'CampSummaryStatsBottleneckRankingInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CampSummaryStatsBottleneckRankingInner object, {
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
    if (object.avgDeviationSeconds != null) {
      yield r'avgDeviationSeconds';
      yield serializers.serialize(
        object.avgDeviationSeconds,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CampSummaryStatsBottleneckRankingInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CampSummaryStatsBottleneckRankingInnerBuilder result,
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
        case r'avgDeviationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.avgDeviationSeconds = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CampSummaryStatsBottleneckRankingInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CampSummaryStatsBottleneckRankingInnerBuilder();
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

