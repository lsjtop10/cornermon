//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/camp_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'camp.g.dart';

/// Camp
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [startAt] 
/// * [endAt] 
/// * [status] 
/// * [bottleneckMinSamples] - 병목 판정 최소 표본 수
/// * [bottleneckRatioPct] - 병목 판정 편차 비율 기준 (%)
@BuiltValue()
abstract class Camp implements Built<Camp, CampBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'startAt')
  DateTime get startAt;

  @BuiltValueField(wireName: r'endAt')
  DateTime get endAt;

  @BuiltValueField(wireName: r'status')
  CampStatus get status;
  // enum statusEnum {  PENDING,  ACTIVE,  ENDED,  };

  /// 병목 판정 최소 표본 수
  @BuiltValueField(wireName: r'bottleneckMinSamples')
  int? get bottleneckMinSamples;

  /// 병목 판정 편차 비율 기준 (%)
  @BuiltValueField(wireName: r'bottleneckRatioPct')
  int? get bottleneckRatioPct;

  Camp._();

  factory Camp([void updates(CampBuilder b)]) = _$Camp;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CampBuilder b) => b
      ..bottleneckMinSamples = 3
      ..bottleneckRatioPct = 20;

  @BuiltValueSerializer(custom: true)
  static Serializer<Camp> get serializer => _$CampSerializer();
}

class _$CampSerializer implements PrimitiveSerializer<Camp> {
  @override
  final Iterable<Type> types = const [Camp, _$Camp];

  @override
  final String wireName = r'Camp';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Camp object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'startAt';
    yield serializers.serialize(
      object.startAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'endAt';
    yield serializers.serialize(
      object.endAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(CampStatus),
    );
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
  }

  @override
  Object serialize(
    Serializers serializers,
    Camp object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CampBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'endAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.endAt = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CampStatus),
          ) as CampStatus;
          result.status = valueDes;
          break;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Camp deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CampBuilder();
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

