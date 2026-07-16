// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/visit_summary_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'track_response.g.dart';

/// TrackResponse
///
/// Properties:
/// * [cornerId] 
/// * [currentVisit] 
/// * [id] 
/// * [operationalStatus] 
/// * [status] 
/// * [trackNo] 
@BuiltValue()
abstract class TrackResponse implements Built<TrackResponse, TrackResponseBuilder> {
  @BuiltValueField(wireName: r'cornerId')
  String? get cornerId;

  @BuiltValueField(wireName: r'currentVisit')
  VisitSummaryResponse? get currentVisit;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'operationalStatus')
  TrackResponseOperationalStatusEnum? get operationalStatus;
  // enum operationalStatusEnum {  IDLE,  BUSY,  };

  @BuiltValueField(wireName: r'status')
  TrackResponseStatusEnum? get status;
  // enum statusEnum {  ACTIVE,  DELETED,  };

  @BuiltValueField(wireName: r'trackNo')
  int? get trackNo;

  TrackResponse._();

  factory TrackResponse([void updates(TrackResponseBuilder b)]) = _$TrackResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackResponse> get serializer => _$TrackResponseSerializer();
}

class _$TrackResponseSerializer implements PrimitiveSerializer<TrackResponse> {
  @override
  final Iterable<Type> types = const [TrackResponse, _$TrackResponse];

  @override
  final String wireName = r'TrackResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.cornerId != null) {
      yield r'cornerId';
      yield serializers.serialize(
        object.cornerId,
        specifiedType: const FullType(String),
      );
    }
    if (object.currentVisit != null) {
      yield r'currentVisit';
      yield serializers.serialize(
        object.currentVisit,
        specifiedType: const FullType(VisitSummaryResponse),
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
        specifiedType: const FullType(TrackResponseOperationalStatusEnum),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(TrackResponseStatusEnum),
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
    TrackResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackResponseBuilder result,
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
        case r'currentVisit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(VisitSummaryResponse),
          ) as VisitSummaryResponse;
          result.currentVisit.replace(valueDes);
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
            specifiedType: const FullType(TrackResponseOperationalStatusEnum),
          ) as TrackResponseOperationalStatusEnum;
          result.operationalStatus = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TrackResponseStatusEnum),
          ) as TrackResponseStatusEnum;
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
  TrackResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackResponseBuilder();
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

class TrackResponseOperationalStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'IDLE')
  static const TrackResponseOperationalStatusEnum IDLE = _$trackResponseOperationalStatusEnum_IDLE;
  @BuiltValueEnumConst(wireName: r'BUSY')
  static const TrackResponseOperationalStatusEnum BUSY = _$trackResponseOperationalStatusEnum_BUSY;

  static Serializer<TrackResponseOperationalStatusEnum> get serializer => _$trackResponseOperationalStatusEnumSerializer;

  const TrackResponseOperationalStatusEnum._(String name): super(name);

  static BuiltSet<TrackResponseOperationalStatusEnum> get values => _$trackResponseOperationalStatusEnumValues;
  static TrackResponseOperationalStatusEnum valueOf(String name) => _$trackResponseOperationalStatusEnumValueOf(name);
}

class TrackResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ACTIVE')
  static const TrackResponseStatusEnum ACTIVE = _$trackResponseStatusEnum_ACTIVE;
  @BuiltValueEnumConst(wireName: r'DELETED')
  static const TrackResponseStatusEnum DELETED = _$trackResponseStatusEnum_DELETED;

  static Serializer<TrackResponseStatusEnum> get serializer => _$trackResponseStatusEnumSerializer;

  const TrackResponseStatusEnum._(String name): super(name);

  static BuiltSet<TrackResponseStatusEnum> get values => _$trackResponseStatusEnumValues;
  static TrackResponseStatusEnum valueOf(String name) => _$trackResponseStatusEnumValueOf(name);
}
