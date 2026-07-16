// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'visit_start_request.g.dart';

/// VisitStartRequest
///
/// Properties:
/// * [groupId] 
/// * [method] 
/// * [qrToken] 
@BuiltValue()
abstract class VisitStartRequest implements Built<VisitStartRequest, VisitStartRequestBuilder> {
  @BuiltValueField(wireName: r'groupId')
  String? get groupId;

  @BuiltValueField(wireName: r'method')
  VisitStartRequestMethodEnum? get method;
  // enum methodEnum {  MANUAL,  };

  @BuiltValueField(wireName: r'qrToken')
  String? get qrToken;

  VisitStartRequest._();

  factory VisitStartRequest([void updates(VisitStartRequestBuilder b)]) = _$VisitStartRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VisitStartRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VisitStartRequest> get serializer => _$VisitStartRequestSerializer();
}

class _$VisitStartRequestSerializer implements PrimitiveSerializer<VisitStartRequest> {
  @override
  final Iterable<Type> types = const [VisitStartRequest, _$VisitStartRequest];

  @override
  final String wireName = r'VisitStartRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VisitStartRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.groupId != null) {
      yield r'groupId';
      yield serializers.serialize(
        object.groupId,
        specifiedType: const FullType(String),
      );
    }
    if (object.method != null) {
      yield r'method';
      yield serializers.serialize(
        object.method,
        specifiedType: const FullType(VisitStartRequestMethodEnum),
      );
    }
    if (object.qrToken != null) {
      yield r'qrToken';
      yield serializers.serialize(
        object.qrToken,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    VisitStartRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required VisitStartRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'groupId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.groupId = valueDes;
          break;
        case r'method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(VisitStartRequestMethodEnum),
          ) as VisitStartRequestMethodEnum;
          result.method = valueDes;
          break;
        case r'qrToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.qrToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VisitStartRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VisitStartRequestBuilder();
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

class VisitStartRequestMethodEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'MANUAL')
  static const VisitStartRequestMethodEnum MANUAL = _$visitStartRequestMethodEnum_MANUAL;

  static Serializer<VisitStartRequestMethodEnum> get serializer => _$visitStartRequestMethodEnumSerializer;

  const VisitStartRequestMethodEnum._(String name): super(name);

  static BuiltSet<VisitStartRequestMethodEnum> get values => _$visitStartRequestMethodEnumValues;
  static VisitStartRequestMethodEnum valueOf(String name) => _$visitStartRequestMethodEnumValueOf(name);
}

