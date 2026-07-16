// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/camp_summary_stats_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/corner_stats_response.dart';
import 'package:cornermon_api_gen/src/model/group_stats_response.dart';
import 'package:cornermon_api_gen/src/model/track_stats_response.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'camp_report_response.g.dart';

/// CampReportResponse
///
/// Properties:
/// * [campId] 
/// * [cornerStats] 
/// * [generatedAt] 
/// * [groupStats] 
/// * [operationalStats] 
/// * [summary] 
/// * [timeline] 
/// * [trackStats] 
@BuiltValue()
abstract class CampReportResponse implements Built<CampReportResponse, CampReportResponseBuilder> {
  @BuiltValueField(wireName: r'campId')
  String? get campId;

  @BuiltValueField(wireName: r'cornerStats')
  BuiltList<CornerStatsResponse>? get cornerStats;

  @BuiltValueField(wireName: r'generatedAt')
  DateTime? get generatedAt;

  @BuiltValueField(wireName: r'groupStats')
  BuiltList<GroupStatsResponse>? get groupStats;

  @BuiltValueField(wireName: r'operationalStats')
  JsonObject? get operationalStats;

  @BuiltValueField(wireName: r'summary')
  CampSummaryStatsResponse? get summary;

  @BuiltValueField(wireName: r'timeline')
  JsonObject? get timeline;

  @BuiltValueField(wireName: r'trackStats')
  BuiltList<TrackStatsResponse>? get trackStats;

  CampReportResponse._();

  factory CampReportResponse([void updates(CampReportResponseBuilder b)]) = _$CampReportResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CampReportResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CampReportResponse> get serializer => _$CampReportResponseSerializer();
}

class _$CampReportResponseSerializer implements PrimitiveSerializer<CampReportResponse> {
  @override
  final Iterable<Type> types = const [CampReportResponse, _$CampReportResponse];

  @override
  final String wireName = r'CampReportResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CampReportResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.campId != null) {
      yield r'campId';
      yield serializers.serialize(
        object.campId,
        specifiedType: const FullType(String),
      );
    }
    if (object.cornerStats != null) {
      yield r'cornerStats';
      yield serializers.serialize(
        object.cornerStats,
        specifiedType: const FullType(BuiltList, [FullType(CornerStatsResponse)]),
      );
    }
    if (object.generatedAt != null) {
      yield r'generatedAt';
      yield serializers.serialize(
        object.generatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.groupStats != null) {
      yield r'groupStats';
      yield serializers.serialize(
        object.groupStats,
        specifiedType: const FullType(BuiltList, [FullType(GroupStatsResponse)]),
      );
    }
    if (object.operationalStats != null) {
      yield r'operationalStats';
      yield serializers.serialize(
        object.operationalStats,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.summary != null) {
      yield r'summary';
      yield serializers.serialize(
        object.summary,
        specifiedType: const FullType(CampSummaryStatsResponse),
      );
    }
    if (object.timeline != null) {
      yield r'timeline';
      yield serializers.serialize(
        object.timeline,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.trackStats != null) {
      yield r'trackStats';
      yield serializers.serialize(
        object.trackStats,
        specifiedType: const FullType(BuiltList, [FullType(TrackStatsResponse)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CampReportResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CampReportResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'campId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.campId = valueDes;
          break;
        case r'cornerStats':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CornerStatsResponse)]),
          ) as BuiltList<CornerStatsResponse>;
          result.cornerStats.replace(valueDes);
          break;
        case r'generatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.generatedAt = valueDes;
          break;
        case r'groupStats':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(GroupStatsResponse)]),
          ) as BuiltList<GroupStatsResponse>;
          result.groupStats.replace(valueDes);
          break;
        case r'operationalStats':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.operationalStats = valueDes;
          break;
        case r'summary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CampSummaryStatsResponse),
          ) as CampSummaryStatsResponse;
          result.summary.replace(valueDes);
          break;
        case r'timeline':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.timeline = valueDes;
          break;
        case r'trackStats':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TrackStatsResponse)]),
          ) as BuiltList<TrackStatsResponse>;
          result.trackStats.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CampReportResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CampReportResponseBuilder();
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
