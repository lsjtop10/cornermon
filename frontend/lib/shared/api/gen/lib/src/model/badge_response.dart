//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'badge_response.g.dart';

/// BadgeResponse
///
/// Properties:
/// * [assignedGroupId] 
/// * [id] 
/// * [qrPayload] 
/// * [shortId] 
/// * [status] 
@BuiltValue()
abstract class BadgeResponse implements Built<BadgeResponse, BadgeResponseBuilder> {
  @BuiltValueField(wireName: r'assignedGroupId')
  String? get assignedGroupId;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'qrPayload')
  String? get qrPayload;

  @BuiltValueField(wireName: r'shortId')
  String? get shortId;

  @BuiltValueField(wireName: r'status')
  BadgeResponseStatusEnum? get status;
  // enum statusEnum {  UNASSIGNED,  ASSIGNED,  };

  BadgeResponse._();

  factory BadgeResponse([void updates(BadgeResponseBuilder b)]) = _$BadgeResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BadgeResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BadgeResponse> get serializer => _$BadgeResponseSerializer();
}

class _$BadgeResponseSerializer implements PrimitiveSerializer<BadgeResponse> {
  @override
  final Iterable<Type> types = const [BadgeResponse, _$BadgeResponse];

  @override
  final String wireName = r'BadgeResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BadgeResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.assignedGroupId != null) {
      yield r'assignedGroupId';
      yield serializers.serialize(
        object.assignedGroupId,
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
    if (object.qrPayload != null) {
      yield r'qrPayload';
      yield serializers.serialize(
        object.qrPayload,
        specifiedType: const FullType(String),
      );
    }
    if (object.shortId != null) {
      yield r'shortId';
      yield serializers.serialize(
        object.shortId,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(BadgeResponseStatusEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BadgeResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BadgeResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'assignedGroupId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.assignedGroupId = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'qrPayload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.qrPayload = valueDes;
          break;
        case r'shortId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.shortId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BadgeResponseStatusEnum),
          ) as BadgeResponseStatusEnum;
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
  BadgeResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BadgeResponseBuilder();
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

class BadgeResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'UNASSIGNED')
  static const BadgeResponseStatusEnum UNASSIGNED = _$badgeResponseStatusEnum_UNASSIGNED;
  @BuiltValueEnumConst(wireName: r'ASSIGNED')
  static const BadgeResponseStatusEnum ASSIGNED = _$badgeResponseStatusEnum_ASSIGNED;

  static Serializer<BadgeResponseStatusEnum> get serializer => _$badgeResponseStatusEnumSerializer;

  const BadgeResponseStatusEnum._(String name): super(name);

  static BuiltSet<BadgeResponseStatusEnum> get values => _$badgeResponseStatusEnumValues;
  static BadgeResponseStatusEnum valueOf(String name) => _$badgeResponseStatusEnumValueOf(name);
}

