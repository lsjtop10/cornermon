//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/bottleneck_ranking_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'camp_summary_stats_response.g.dart';

/// CampSummaryStatsResponse
///
/// Properties:
/// * [avgDeviationSeconds] 
/// * [bottleneckRanking] 
/// * [completionRate] 
/// * [exceptionApprovalCount] 
/// * [finishedGroupCount] 
/// * [manualVisitRatio] 
/// * [programDurationSeconds] 
/// * [ruleOverrideCount] 
/// * [totalGroups] 
/// * [totalVisits] 
/// * [trackOperationCount] 
/// * [visitCompletionRate] 
@BuiltValue()
abstract class CampSummaryStatsResponse implements Built<CampSummaryStatsResponse, CampSummaryStatsResponseBuilder> {
  @BuiltValueField(wireName: r'avgDeviationSeconds')
  num? get avgDeviationSeconds;

  @BuiltValueField(wireName: r'bottleneckRanking')
  BuiltList<BottleneckRankingResponse>? get bottleneckRanking;

  @BuiltValueField(wireName: r'completionRate')
  num? get completionRate;

  @BuiltValueField(wireName: r'exceptionApprovalCount')
  int? get exceptionApprovalCount;

  @BuiltValueField(wireName: r'finishedGroupCount')
  int? get finishedGroupCount;

  @BuiltValueField(wireName: r'manualVisitRatio')
  num? get manualVisitRatio;

  @BuiltValueField(wireName: r'programDurationSeconds')
  int? get programDurationSeconds;

  @BuiltValueField(wireName: r'ruleOverrideCount')
  int? get ruleOverrideCount;

  @BuiltValueField(wireName: r'totalGroups')
  int? get totalGroups;

  @BuiltValueField(wireName: r'totalVisits')
  int? get totalVisits;

  @BuiltValueField(wireName: r'trackOperationCount')
  int? get trackOperationCount;

  @BuiltValueField(wireName: r'visitCompletionRate')
  num? get visitCompletionRate;

  CampSummaryStatsResponse._();

  factory CampSummaryStatsResponse([void updates(CampSummaryStatsResponseBuilder b)]) = _$CampSummaryStatsResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CampSummaryStatsResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CampSummaryStatsResponse> get serializer => _$CampSummaryStatsResponseSerializer();
}

class _$CampSummaryStatsResponseSerializer implements PrimitiveSerializer<CampSummaryStatsResponse> {
  @override
  final Iterable<Type> types = const [CampSummaryStatsResponse, _$CampSummaryStatsResponse];

  @override
  final String wireName = r'CampSummaryStatsResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CampSummaryStatsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.avgDeviationSeconds != null) {
      yield r'avgDeviationSeconds';
      yield serializers.serialize(
        object.avgDeviationSeconds,
        specifiedType: const FullType(num),
      );
    }
    if (object.bottleneckRanking != null) {
      yield r'bottleneckRanking';
      yield serializers.serialize(
        object.bottleneckRanking,
        specifiedType: const FullType(BuiltList, [FullType(BottleneckRankingResponse)]),
      );
    }
    if (object.completionRate != null) {
      yield r'completionRate';
      yield serializers.serialize(
        object.completionRate,
        specifiedType: const FullType(num),
      );
    }
    if (object.exceptionApprovalCount != null) {
      yield r'exceptionApprovalCount';
      yield serializers.serialize(
        object.exceptionApprovalCount,
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
    if (object.manualVisitRatio != null) {
      yield r'manualVisitRatio';
      yield serializers.serialize(
        object.manualVisitRatio,
        specifiedType: const FullType(num),
      );
    }
    if (object.programDurationSeconds != null) {
      yield r'programDurationSeconds';
      yield serializers.serialize(
        object.programDurationSeconds,
        specifiedType: const FullType(int),
      );
    }
    if (object.ruleOverrideCount != null) {
      yield r'ruleOverrideCount';
      yield serializers.serialize(
        object.ruleOverrideCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.totalGroups != null) {
      yield r'totalGroups';
      yield serializers.serialize(
        object.totalGroups,
        specifiedType: const FullType(int),
      );
    }
    if (object.totalVisits != null) {
      yield r'totalVisits';
      yield serializers.serialize(
        object.totalVisits,
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
    if (object.visitCompletionRate != null) {
      yield r'visitCompletionRate';
      yield serializers.serialize(
        object.visitCompletionRate,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CampSummaryStatsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CampSummaryStatsResponseBuilder result,
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
        case r'bottleneckRanking':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BottleneckRankingResponse)]),
          ) as BuiltList<BottleneckRankingResponse>;
          result.bottleneckRanking.replace(valueDes);
          break;
        case r'completionRate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.completionRate = valueDes;
          break;
        case r'exceptionApprovalCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.exceptionApprovalCount = valueDes;
          break;
        case r'finishedGroupCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.finishedGroupCount = valueDes;
          break;
        case r'manualVisitRatio':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.manualVisitRatio = valueDes;
          break;
        case r'programDurationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.programDurationSeconds = valueDes;
          break;
        case r'ruleOverrideCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ruleOverrideCount = valueDes;
          break;
        case r'totalGroups':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalGroups = valueDes;
          break;
        case r'totalVisits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalVisits = valueDes;
          break;
        case r'trackOperationCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.trackOperationCount = valueDes;
          break;
        case r'visitCompletionRate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.visitCompletionRate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CampSummaryStatsResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CampSummaryStatsResponseBuilder();
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

