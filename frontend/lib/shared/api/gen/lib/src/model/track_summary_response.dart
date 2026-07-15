// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'track_summary_response.g.dart';

/// TrackSummaryResponse
///
/// Properties:
/// * [cornerId] 
/// * [id] 
/// * [operationalStatus] 
/// * [status] 
/// * [trackNo] 
@BuiltValue()
abstract class TrackSummaryResponse implements Built<TrackSummaryResponse, TrackSummaryResponseBuilder> {
  @BuiltValueField(wireName: r'cornerId')
  String? get cornerId;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'operationalStatus')
  TrackSummaryResponseOperationalStatusEnum? get operationalStatus;
  // enum operationalStatusEnum {  IDLE,  BUSY,  };

  @BuiltValueField(wireName: r'status')
  TrackSummaryResponseStatusEnum? get status;
  // enum statusEnum {  ACTIVE,  DELETED,  };

  @BuiltValueField(wireName: r'trackNo')
  int? get trackNo;

  TrackSummaryResponse._();

  factory TrackSummaryResponse([void updates(TrackSummaryResponseBuilder b)]) = _$TrackSummaryResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackSummaryResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackSummaryResponse> get serializer => _$TrackSummaryResponseSerializer();
}

class _$TrackSummaryResponseSerializer implements PrimitiveSerializer<TrackSummaryResponse> {
  @override
  final Iterable<Type> types = const [TrackSummaryResponse, _$TrackSummaryResponse];

  @override
  final String wireName = r'TrackSummaryResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackSummaryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.cornerId != null) {
      yield r'cornerId';
      yield serializers.serialize(
        object.cornerId,
        specifiedType: const FullType(String),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.operationalStatus != null) {
      yield r'operationalStatus';
      yield serializers.serialize(
        object.operationalStatus,
        specifiedType: const FullType(TrackSummaryResponseOperationalStatusEnum),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(TrackSummaryResponseStatusEnum),
      );
    }
    if (object.trackNo != null) {
      yield r'trackNo';
      yield serializers.serialize(
        object.trackNo,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackSummaryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackSummaryResponseBuilder result,
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
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'operationalStatus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TrackSummaryResponseOperationalStatusEnum),
          ) as TrackSummaryResponseOperationalStatusEnum;
          result.operationalStatus = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TrackSummaryResponseStatusEnum),
          ) as TrackSummaryResponseStatusEnum;
          result.status = valueDes;
          break;
        case r'trackNo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.trackNo = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackSummaryResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackSummaryResponseBuilder();
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

class TrackSummaryResponseOperationalStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'IDLE')
  static const TrackSummaryResponseOperationalStatusEnum IDLE = _$trackSummaryResponseOperationalStatusEnum_IDLE;
  @BuiltValueEnumConst(wireName: r'BUSY')
  static const TrackSummaryResponseOperationalStatusEnum BUSY = _$trackSummaryResponseOperationalStatusEnum_BUSY;

  static Serializer<TrackSummaryResponseOperationalStatusEnum> get serializer => _$trackSummaryResponseOperationalStatusEnumSerializer;

  const TrackSummaryResponseOperationalStatusEnum._(String name): super(name);

  static BuiltSet<TrackSummaryResponseOperationalStatusEnum> get values => _$trackSummaryResponseOperationalStatusEnumValues;
  static TrackSummaryResponseOperationalStatusEnum valueOf(String name) => _$trackSummaryResponseOperationalStatusEnumValueOf(name);
}

class TrackSummaryResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ACTIVE')
  static const TrackSummaryResponseStatusEnum ACTIVE = _$trackSummaryResponseStatusEnum_ACTIVE;
  @BuiltValueEnumConst(wireName: r'DELETED')
  static const TrackSummaryResponseStatusEnum DELETED = _$trackSummaryResponseStatusEnum_DELETED;

  static Serializer<TrackSummaryResponseStatusEnum> get serializer => _$trackSummaryResponseStatusEnumSerializer;

  const TrackSummaryResponseStatusEnum._(String name): super(name);

  static BuiltSet<TrackSummaryResponseStatusEnum> get values => _$trackSummaryResponseStatusEnumValues;
  static TrackSummaryResponseStatusEnum valueOf(String name) => _$trackSummaryResponseStatusEnumValueOf(name);
}
