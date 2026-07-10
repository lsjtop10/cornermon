//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/corner_operational_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reports_live_summary_get200_response_corners_inner.g.dart';

/// ReportsLiveSummaryGet200ResponseCornersInner
///
/// Properties:
/// * [cornerId] 
/// * [cornerName] 
/// * [status] 
/// * [isBottleneck] 
/// * [completedVisitCount] 
@BuiltValue()
abstract class ReportsLiveSummaryGet200ResponseCornersInner implements Built<ReportsLiveSummaryGet200ResponseCornersInner, ReportsLiveSummaryGet200ResponseCornersInnerBuilder> {
  @BuiltValueField(wireName: r'cornerId')
  String? get cornerId;

  @BuiltValueField(wireName: r'cornerName')
  String? get cornerName;

  @BuiltValueField(wireName: r'status')
  CornerOperationalStatus? get status;
  // enum statusEnum {  INACTIVE,  IDLE,  BUSY,  };

  @BuiltValueField(wireName: r'isBottleneck')
  bool? get isBottleneck;

  @BuiltValueField(wireName: r'completedVisitCount')
  int? get completedVisitCount;

  ReportsLiveSummaryGet200ResponseCornersInner._();

  factory ReportsLiveSummaryGet200ResponseCornersInner([void updates(ReportsLiveSummaryGet200ResponseCornersInnerBuilder b)]) = _$ReportsLiveSummaryGet200ResponseCornersInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReportsLiveSummaryGet200ResponseCornersInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReportsLiveSummaryGet200ResponseCornersInner> get serializer => _$ReportsLiveSummaryGet200ResponseCornersInnerSerializer();
}

class _$ReportsLiveSummaryGet200ResponseCornersInnerSerializer implements PrimitiveSerializer<ReportsLiveSummaryGet200ResponseCornersInner> {
  @override
  final Iterable<Type> types = const [ReportsLiveSummaryGet200ResponseCornersInner, _$ReportsLiveSummaryGet200ResponseCornersInner];

  @override
  final String wireName = r'ReportsLiveSummaryGet200ResponseCornersInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReportsLiveSummaryGet200ResponseCornersInner object, {
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
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(CornerOperationalStatus),
      );
    }
    if (object.isBottleneck != null) {
      yield r'isBottleneck';
      yield serializers.serialize(
        object.isBottleneck,
        specifiedType: const FullType(bool),
      );
    }
    if (object.completedVisitCount != null) {
      yield r'completedVisitCount';
      yield serializers.serialize(
        object.completedVisitCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ReportsLiveSummaryGet200ResponseCornersInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReportsLiveSummaryGet200ResponseCornersInnerBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CornerOperationalStatus),
          ) as CornerOperationalStatus;
          result.status = valueDes;
          break;
        case r'isBottleneck':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isBottleneck = valueDes;
          break;
        case r'completedVisitCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.completedVisitCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReportsLiveSummaryGet200ResponseCornersInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReportsLiveSummaryGet200ResponseCornersInnerBuilder();
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

