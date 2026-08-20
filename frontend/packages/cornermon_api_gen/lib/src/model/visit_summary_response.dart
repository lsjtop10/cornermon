//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'visit_summary_response.g.dart';

/// VisitSummaryResponse
///
/// Properties:
/// * [cornerId] 
/// * [deviationSeconds] 
/// * [durationSeconds] 
/// * [endedAt] 
/// * [groupId] 
/// * [id] 
/// * [inputMethod] 
/// * [startedAt] 
/// * [status] 
/// * [trackId] 
@BuiltValue()
abstract class VisitSummaryResponse implements Built<VisitSummaryResponse, VisitSummaryResponseBuilder> {
  @BuiltValueField(wireName: r'cornerId')
  String? get cornerId;

  @BuiltValueField(wireName: r'deviationSeconds')
  int? get deviationSeconds;

  @BuiltValueField(wireName: r'durationSeconds')
  int? get durationSeconds;

  @BuiltValueField(wireName: r'endedAt')
  DateTime? get endedAt;

  @BuiltValueField(wireName: r'groupId')
  String? get groupId;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'inputMethod')
  VisitSummaryResponseInputMethodEnum? get inputMethod;
  // enum inputMethodEnum {  QR_SCAN,  MANUAL,  };

  @BuiltValueField(wireName: r'startedAt')
  DateTime? get startedAt;

  @BuiltValueField(wireName: r'status')
  VisitSummaryResponseStatusEnum? get status;
  // enum statusEnum {  IN_PROGRESS,  COMPLETED,  };

  @BuiltValueField(wireName: r'trackId')
  String? get trackId;

  VisitSummaryResponse._();

  factory VisitSummaryResponse([void updates(VisitSummaryResponseBuilder b)]) = _$VisitSummaryResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VisitSummaryResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VisitSummaryResponse> get serializer => _$VisitSummaryResponseSerializer();
}

class _$VisitSummaryResponseSerializer implements PrimitiveSerializer<VisitSummaryResponse> {
  @override
  final Iterable<Type> types = const [VisitSummaryResponse, _$VisitSummaryResponse];

  @override
  final String wireName = r'VisitSummaryResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VisitSummaryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.cornerId != null) {
      yield r'cornerId';
      yield serializers.serialize(
        object.cornerId,
        specifiedType: const FullType(String),
      );
    }
    if (object.deviationSeconds != null) {
      yield r'deviationSeconds';
      yield serializers.serialize(
        object.deviationSeconds,
        specifiedType: const FullType(int),
      );
    }
    if (object.durationSeconds != null) {
      yield r'durationSeconds';
      yield serializers.serialize(
        object.durationSeconds,
        specifiedType: const FullType(int),
      );
    }
    if (object.endedAt != null) {
      yield r'endedAt';
      yield serializers.serialize(
        object.endedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.groupId != null) {
      yield r'groupId';
      yield serializers.serialize(
        object.groupId,
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
    if (object.inputMethod != null) {
      yield r'inputMethod';
      yield serializers.serialize(
        object.inputMethod,
        specifiedType: const FullType(VisitSummaryResponseInputMethodEnum),
      );
    }
    if (object.startedAt != null) {
      yield r'startedAt';
      yield serializers.serialize(
        object.startedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(VisitSummaryResponseStatusEnum),
      );
    }
    if (object.trackId != null) {
      yield r'trackId';
      yield serializers.serialize(
        object.trackId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    VisitSummaryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required VisitSummaryResponseBuilder result,
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
        case r'deviationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.deviationSeconds = valueDes;
          break;
        case r'durationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.durationSeconds = valueDes;
          break;
        case r'endedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.endedAt = valueDes;
          break;
        case r'groupId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.groupId = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'inputMethod':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(VisitSummaryResponseInputMethodEnum),
          ) as VisitSummaryResponseInputMethodEnum;
          result.inputMethod = valueDes;
          break;
        case r'startedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startedAt = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(VisitSummaryResponseStatusEnum),
          ) as VisitSummaryResponseStatusEnum;
          result.status = valueDes;
          break;
        case r'trackId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.trackId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VisitSummaryResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VisitSummaryResponseBuilder();
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

class VisitSummaryResponseInputMethodEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'QR_SCAN')
  static const VisitSummaryResponseInputMethodEnum QR_SCAN = _$visitSummaryResponseInputMethodEnum_QR_SCAN;
  @BuiltValueEnumConst(wireName: r'MANUAL')
  static const VisitSummaryResponseInputMethodEnum MANUAL = _$visitSummaryResponseInputMethodEnum_MANUAL;

  static Serializer<VisitSummaryResponseInputMethodEnum> get serializer => _$visitSummaryResponseInputMethodEnumSerializer;

  const VisitSummaryResponseInputMethodEnum._(String name): super(name);

  static BuiltSet<VisitSummaryResponseInputMethodEnum> get values => _$visitSummaryResponseInputMethodEnumValues;
  static VisitSummaryResponseInputMethodEnum valueOf(String name) => _$visitSummaryResponseInputMethodEnumValueOf(name);
}

class VisitSummaryResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'IN_PROGRESS')
  static const VisitSummaryResponseStatusEnum IN_PROGRESS = _$visitSummaryResponseStatusEnum_IN_PROGRESS;
  @BuiltValueEnumConst(wireName: r'COMPLETED')
  static const VisitSummaryResponseStatusEnum COMPLETED = _$visitSummaryResponseStatusEnum_COMPLETED;

  static Serializer<VisitSummaryResponseStatusEnum> get serializer => _$visitSummaryResponseStatusEnumSerializer;

  const VisitSummaryResponseStatusEnum._(String name): super(name);

  static BuiltSet<VisitSummaryResponseStatusEnum> get values => _$visitSummaryResponseStatusEnumValues;
  static VisitSummaryResponseStatusEnum valueOf(String name) => _$visitSummaryResponseStatusEnumValueOf(name);
}

