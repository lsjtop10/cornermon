//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/camp_summary_stats_bottleneck_ranking_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'camp_summary_stats.g.dart';

/// CampSummaryStats
///
/// Properties:
/// * [totalGroups] 
/// * [finishedGroupCount] 
/// * [completionRate] - 완주율 (0.0 ~ 1.0)
/// * [totalVisits] 
/// * [visitCompletionRate] - 방문 완료율 (완료 방문 수 / 이론상 최대 200)
/// * [programDurationSeconds] 
/// * [avgDeviationSeconds] 
/// * [manualVisitRatio] 
/// * [ruleOverrideCount] 
/// * [trackOperationCount] 
/// * [exceptionApprovalCount] 
/// * [bottleneckRanking] - 코너를 평균편차 기준 내림차순 정렬한 병목 랭킹
@BuiltValue()
abstract class CampSummaryStats implements Built<CampSummaryStats, CampSummaryStatsBuilder> {
  @BuiltValueField(wireName: r'totalGroups')
  int? get totalGroups;

  @BuiltValueField(wireName: r'finishedGroupCount')
  int? get finishedGroupCount;

  /// 완주율 (0.0 ~ 1.0)
  @BuiltValueField(wireName: r'completionRate')
  double? get completionRate;

  @BuiltValueField(wireName: r'totalVisits')
  int? get totalVisits;

  /// 방문 완료율 (완료 방문 수 / 이론상 최대 200)
  @BuiltValueField(wireName: r'visitCompletionRate')
  double? get visitCompletionRate;

  @BuiltValueField(wireName: r'programDurationSeconds')
  int? get programDurationSeconds;

  @BuiltValueField(wireName: r'avgDeviationSeconds')
  double? get avgDeviationSeconds;

  @BuiltValueField(wireName: r'manualVisitRatio')
  double? get manualVisitRatio;

  @BuiltValueField(wireName: r'ruleOverrideCount')
  int? get ruleOverrideCount;

  @BuiltValueField(wireName: r'trackOperationCount')
  int? get trackOperationCount;

  @BuiltValueField(wireName: r'exceptionApprovalCount')
  int? get exceptionApprovalCount;

  /// 코너를 평균편차 기준 내림차순 정렬한 병목 랭킹
  @BuiltValueField(wireName: r'bottleneckRanking')
  BuiltList<CampSummaryStatsBottleneckRankingInner>? get bottleneckRanking;

  CampSummaryStats._();

  factory CampSummaryStats([void updates(CampSummaryStatsBuilder b)]) = _$CampSummaryStats;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CampSummaryStatsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CampSummaryStats> get serializer => _$CampSummaryStatsSerializer();
}

class _$CampSummaryStatsSerializer implements PrimitiveSerializer<CampSummaryStats> {
  @override
  final Iterable<Type> types = const [CampSummaryStats, _$CampSummaryStats];

  @override
  final String wireName = r'CampSummaryStats';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CampSummaryStats object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.totalGroups != null) {
      yield r'totalGroups';
      yield serializers.serialize(
        object.totalGroups,
        specifiedType: const FullType(int),
      );
    }
    if (object.finishedGroupCount != null) {
      yield r'finishedGroupCount';
      yield serializers.serialize(
        object.finishedGroupCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.completionRate != null) {
      yield r'completionRate';
      yield serializers.serialize(
        object.completionRate,
        specifiedType: const FullType(double),
      );
    }
    if (object.totalVisits != null) {
      yield r'totalVisits';
      yield serializers.serialize(
        object.totalVisits,
        specifiedType: const FullType(int),
      );
    }
    if (object.visitCompletionRate != null) {
      yield r'visitCompletionRate';
      yield serializers.serialize(
        object.visitCompletionRate,
        specifiedType: const FullType(double),
      );
    }
    if (object.programDurationSeconds != null) {
      yield r'programDurationSeconds';
      yield serializers.serialize(
        object.programDurationSeconds,
        specifiedType: const FullType(int),
      );
    }
    if (object.avgDeviationSeconds != null) {
      yield r'avgDeviationSeconds';
      yield serializers.serialize(
        object.avgDeviationSeconds,
        specifiedType: const FullType(double),
      );
    }
    if (object.manualVisitRatio != null) {
      yield r'manualVisitRatio';
      yield serializers.serialize(
        object.manualVisitRatio,
        specifiedType: const FullType(double),
      );
    }
    if (object.ruleOverrideCount != null) {
      yield r'ruleOverrideCount';
      yield serializers.serialize(
        object.ruleOverrideCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.trackOperationCount != null) {
      yield r'trackOperationCount';
      yield serializers.serialize(
        object.trackOperationCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.exceptionApprovalCount != null) {
      yield r'exceptionApprovalCount';
      yield serializers.serialize(
        object.exceptionApprovalCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.bottleneckRanking != null) {
      yield r'bottleneckRanking';
      yield serializers.serialize(
        object.bottleneckRanking,
        specifiedType: const FullType(BuiltList, [FullType(CampSummaryStatsBottleneckRankingInner)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CampSummaryStats object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CampSummaryStatsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'totalGroups':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalGroups = valueDes;
          break;
        case r'finishedGroupCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.finishedGroupCount = valueDes;
          break;
        case r'completionRate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.completionRate = valueDes;
          break;
        case r'totalVisits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalVisits = valueDes;
          break;
        case r'visitCompletionRate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.visitCompletionRate = valueDes;
          break;
        case r'programDurationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.programDurationSeconds = valueDes;
          break;
        case r'avgDeviationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.avgDeviationSeconds = valueDes;
          break;
        case r'manualVisitRatio':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.manualVisitRatio = valueDes;
          break;
        case r'ruleOverrideCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ruleOverrideCount = valueDes;
          break;
        case r'trackOperationCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.trackOperationCount = valueDes;
          break;
        case r'exceptionApprovalCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.exceptionApprovalCount = valueDes;
          break;
        case r'bottleneckRanking':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CampSummaryStatsBottleneckRankingInner)]),
          ) as BuiltList<CampSummaryStatsBottleneckRankingInner>;
          result.bottleneckRanking.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CampSummaryStats deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CampSummaryStatsBuilder();
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

