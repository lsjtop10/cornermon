// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'camp_response.g.dart';

/// CampResponse
///
/// Properties:
/// * [bottleneckMinSamples] 
/// * [bottleneckRatioPct] 
/// * [endAt] 
/// * [id] 
/// * [name] 
/// * [startAt] 
/// * [status] 
@BuiltValue()
abstract class CampResponse implements Built<CampResponse, CampResponseBuilder> {
  @BuiltValueField(wireName: r'bottleneckMinSamples')
  int? get bottleneckMinSamples;

  @BuiltValueField(wireName: r'bottleneckRatioPct')
  int? get bottleneckRatioPct;

  @BuiltValueField(wireName: r'endAt')
  DateTime? get endAt;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'startAt')
  DateTime? get startAt;

  @BuiltValueField(wireName: r'status')
  CampResponseStatusEnum? get status;
  // enum statusEnum {  PENDING,  ACTIVE,  ENDED,  };

  CampResponse._();

  factory CampResponse([void updates(CampResponseBuilder b)]) = _$CampResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CampResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CampResponse> get serializer => _$CampResponseSerializer();
}

class _$CampResponseSerializer implements PrimitiveSerializer<CampResponse> {
  @override
  final Iterable<Type> types = const [CampResponse, _$CampResponse];

  @override
  final String wireName = r'CampResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CampResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.bottleneckMinSamples != null) {
      yield r'bottleneckMinSamples';
      yield serializers.serialize(
        object.bottleneckMinSamples,
        specifiedType: const FullType(int),
      );
    }
    if (object.bottleneckRatioPct != null) {
      yield r'bottleneckRatioPct';
      yield serializers.serialize(
        object.bottleneckRatioPct,
        specifiedType: const FullType(int),
      );
    }
    if (object.endAt != null) {
      yield r'endAt';
      yield serializers.serialize(
        object.endAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.startAt != null) {
      yield r'startAt';
      yield serializers.serialize(
        object.startAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(CampResponseStatusEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CampResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CampResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'bottleneckMinSamples':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.bottleneckMinSamples = valueDes;
          break;
        case r'bottleneckRatioPct':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.bottleneckRatioPct = valueDes;
          break;
        case r'endAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.endAt = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'startAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startAt = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CampResponseStatusEnum),
          ) as CampResponseStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CampResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CampResponseBuilder();
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

class CampResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PENDING')
  static const CampResponseStatusEnum PENDING = _$campResponseStatusEnum_PENDING;
  @BuiltValueEnumConst(wireName: r'ACTIVE')
  static const CampResponseStatusEnum ACTIVE = _$campResponseStatusEnum_ACTIVE;
  @BuiltValueEnumConst(wireName: r'ENDED')
  static const CampResponseStatusEnum ENDED = _$campResponseStatusEnum_ENDED;

  static Serializer<CampResponseStatusEnum> get serializer => _$campResponseStatusEnumSerializer;

  const CampResponseStatusEnum._(String name): super(name);

  static BuiltSet<CampResponseStatusEnum> get values => _$campResponseStatusEnumValues;
  static CampResponseStatusEnum valueOf(String name) => _$campResponseStatusEnumValueOf(name);
}

