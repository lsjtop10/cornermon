//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/timeline_stats.dart';
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/group_stats.dart';
import 'package:cornermon_api_gen/src/model/corner_stats.dart';
import 'package:cornermon_api_gen/src/model/track_stats.dart';
import 'package:cornermon_api_gen/src/model/camp_summary_stats.dart';
import 'package:cornermon_api_gen/src/model/operational_stats.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'camp_report.g.dart';

/// CampReport
///
/// Properties:
/// * [campId] 
/// * [generatedAt] 
/// * [summary] 
/// * [cornerStats] 
/// * [trackStats] 
/// * [groupStats] 
/// * [timeline] 
/// * [operationalStats] 
@BuiltValue()
abstract class CampReport implements Built<CampReport, CampReportBuilder> {
  @BuiltValueField(wireName: r'campId')
  String get campId;

  @BuiltValueField(wireName: r'generatedAt')
  DateTime get generatedAt;

  @BuiltValueField(wireName: r'summary')
  CampSummaryStats get summary;

  @BuiltValueField(wireName: r'cornerStats')
  BuiltList<CornerStats> get cornerStats;

  @BuiltValueField(wireName: r'trackStats')
  BuiltList<TrackStats>? get trackStats;

  @BuiltValueField(wireName: r'groupStats')
  BuiltList<GroupStats> get groupStats;

  @BuiltValueField(wireName: r'timeline')
  TimelineStats? get timeline;

  @BuiltValueField(wireName: r'operationalStats')
  OperationalStats? get operationalStats;

  CampReport._();

  factory CampReport([void updates(CampReportBuilder b)]) = _$CampReport;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CampReportBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CampReport> get serializer => _$CampReportSerializer();
}

class _$CampReportSerializer implements PrimitiveSerializer<CampReport> {
  @override
  final Iterable<Type> types = const [CampReport, _$CampReport];

  @override
  final String wireName = r'CampReport';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CampReport object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'campId';
    yield serializers.serialize(
      object.campId,
      specifiedType: const FullType(String),
    );
    yield r'generatedAt';
    yield serializers.serialize(
      object.generatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'summary';
    yield serializers.serialize(
      object.summary,
      specifiedType: const FullType(CampSummaryStats),
    );
    yield r'cornerStats';
    yield serializers.serialize(
      object.cornerStats,
      specifiedType: const FullType(BuiltList, [FullType(CornerStats)]),
    );
    if (object.trackStats != null) {
      yield r'trackStats';
      yield serializers.serialize(
        object.trackStats,
        specifiedType: const FullType(BuiltList, [FullType(TrackStats)]),
      );
    }
    yield r'groupStats';
    yield serializers.serialize(
      object.groupStats,
      specifiedType: const FullType(BuiltList, [FullType(GroupStats)]),
    );
    if (object.timeline != null) {
      yield r'timeline';
      yield serializers.serialize(
        object.timeline,
        specifiedType: const FullType(TimelineStats),
      );
    }
    if (object.operationalStats != null) {
      yield r'operationalStats';
      yield serializers.serialize(
        object.operationalStats,
        specifiedType: const FullType(OperationalStats),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CampReport object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CampReportBuilder result,
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
        case r'generatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.generatedAt = valueDes;
          break;
        case r'summary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CampSummaryStats),
          ) as CampSummaryStats;
          result.summary.replace(valueDes);
          break;
        case r'cornerStats':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CornerStats)]),
          ) as BuiltList<CornerStats>;
          result.cornerStats.replace(valueDes);
          break;
        case r'trackStats':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TrackStats)]),
          ) as BuiltList<TrackStats>;
          result.trackStats.replace(valueDes);
          break;
        case r'groupStats':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(GroupStats)]),
          ) as BuiltList<GroupStats>;
          result.groupStats.replace(valueDes);
          break;
        case r'timeline':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TimelineStats),
          ) as TimelineStats;
          result.timeline.replace(valueDes);
          break;
        case r'operationalStats':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OperationalStats),
          ) as OperationalStats;
          result.operationalStats.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CampReport deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CampReportBuilder();
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

