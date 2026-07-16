// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/corner_metric_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/track_summary_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'corner_response.g.dart';

/// CornerResponse
///
/// Properties:
/// * [activeTracks] 
/// * [campId] 
/// * [cornerMetric] 
/// * [id] 
/// * [isBottleneck] 
/// * [name] 
/// * [status] 
/// * [targetMinutes] 
@BuiltValue()
abstract class CornerResponse implements Built<CornerResponse, CornerResponseBuilder> {
  @BuiltValueField(wireName: r'activeTracks')
  BuiltList<TrackSummaryResponse>? get activeTracks;

  @BuiltValueField(wireName: r'campId')
  String? get campId;

  @BuiltValueField(wireName: r'cornerMetric')
  CornerMetricResponse? get cornerMetric;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'isBottleneck')
  bool? get isBottleneck;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'status')
  CornerResponseStatusEnum? get status;
  // enum statusEnum {  INACTIVE,  IDLE,  BUSY,  };

  @BuiltValueField(wireName: r'targetMinutes')
  int? get targetMinutes;

  CornerResponse._();

  factory CornerResponse([void updates(CornerResponseBuilder b)]) = _$CornerResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CornerResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CornerResponse> get serializer => _$CornerResponseSerializer();
}

class _$CornerResponseSerializer implements PrimitiveSerializer<CornerResponse> {
  @override
  final Iterable<Type> types = const [CornerResponse, _$CornerResponse];

  @override
  final String wireName = r'CornerResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CornerResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.activeTracks != null) {
      yield r'activeTracks';
      yield serializers.serialize(
        object.activeTracks,
        specifiedType: const FullType(BuiltList, [FullType(TrackSummaryResponse)]),
      );
    }
    if (object.campId != null) {
      yield r'campId';
      yield serializers.serialize(
        object.campId,
        specifiedType: const FullType(String),
      );
    }
    if (object.cornerMetric != null) {
      yield r'cornerMetric';
      yield serializers.serialize(
        object.cornerMetric,
        specifiedType: const FullType(CornerMetricResponse),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.isBottleneck != null) {
      yield r'isBottleneck';
      yield serializers.serialize(
        object.isBottleneck,
        specifiedType: const FullType(bool),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(CornerResponseStatusEnum),
      );
    }
    if (object.targetMinutes != null) {
      yield r'targetMinutes';
      yield serializers.serialize(
        object.targetMinutes,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CornerResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CornerResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'activeTracks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TrackSummaryResponse)]),
          ) as BuiltList<TrackSummaryResponse>;
          result.activeTracks.replace(valueDes);
          break;
        case r'campId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.campId = valueDes;
          break;
        case r'cornerMetric':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CornerMetricResponse),
          ) as CornerMetricResponse;
          result.cornerMetric.replace(valueDes);
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'isBottleneck':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isBottleneck = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CornerResponseStatusEnum),
          ) as CornerResponseStatusEnum;
          result.status = valueDes;
          break;
        case r'targetMinutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.targetMinutes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CornerResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CornerResponseBuilder();
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

class CornerResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'INACTIVE')
  static const CornerResponseStatusEnum INACTIVE = _$cornerResponseStatusEnum_INACTIVE;
  @BuiltValueEnumConst(wireName: r'IDLE')
  static const CornerResponseStatusEnum IDLE = _$cornerResponseStatusEnum_IDLE;
  @BuiltValueEnumConst(wireName: r'BUSY')
  static const CornerResponseStatusEnum BUSY = _$cornerResponseStatusEnum_BUSY;

  static Serializer<CornerResponseStatusEnum> get serializer => _$cornerResponseStatusEnumSerializer;

  const CornerResponseStatusEnum._(String name): super(name);

  static BuiltSet<CornerResponseStatusEnum> get values => _$cornerResponseStatusEnumValues;
  static CornerResponseStatusEnum valueOf(String name) => _$cornerResponseStatusEnumValueOf(name);
}

