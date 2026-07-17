// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_registration_created_response.g.dart';

/// DeviceRegistrationCreatedResponse
///
/// Properties:
/// * [approvedAt] 
/// * [createdAt] 
/// * [deviceModel] 
/// * [deviceName] 
/// * [deviceToken] 
/// * [displayName] 
/// * [failedPinAttempts] 
/// * [id] 
/// * [lockedUntil] 
/// * [status] 
@BuiltValue()
abstract class DeviceRegistrationCreatedResponse implements Built<DeviceRegistrationCreatedResponse, DeviceRegistrationCreatedResponseBuilder> {
  @BuiltValueField(wireName: r'approvedAt')
  DateTime? get approvedAt;

  @BuiltValueField(wireName: r'createdAt')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'deviceModel')
  String? get deviceModel;

  @BuiltValueField(wireName: r'deviceName')
  String? get deviceName;

  @BuiltValueField(wireName: r'deviceToken')
  String? get deviceToken;

  @BuiltValueField(wireName: r'displayName')
  String? get displayName;

  @BuiltValueField(wireName: r'failedPinAttempts')
  int? get failedPinAttempts;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'lockedUntil')
  DateTime? get lockedUntil;

  @BuiltValueField(wireName: r'status')
  DeviceRegistrationCreatedResponseStatusEnum? get status;
  // enum statusEnum {  PENDING,  APPROVED,  REJECTED,  REVOKED,  };

  DeviceRegistrationCreatedResponse._();

  factory DeviceRegistrationCreatedResponse([void updates(DeviceRegistrationCreatedResponseBuilder b)]) = _$DeviceRegistrationCreatedResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceRegistrationCreatedResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeviceRegistrationCreatedResponse> get serializer => _$DeviceRegistrationCreatedResponseSerializer();
}

class _$DeviceRegistrationCreatedResponseSerializer implements PrimitiveSerializer<DeviceRegistrationCreatedResponse> {
  @override
  final Iterable<Type> types = const [DeviceRegistrationCreatedResponse, _$DeviceRegistrationCreatedResponse];

  @override
  final String wireName = r'DeviceRegistrationCreatedResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeviceRegistrationCreatedResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.approvedAt != null) {
      yield r'approvedAt';
      yield serializers.serialize(
        object.approvedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.createdAt != null) {
      yield r'createdAt';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.deviceModel != null) {
      yield r'deviceModel';
      yield serializers.serialize(
        object.deviceModel,
        specifiedType: const FullType(String),
      );
    }
    if (object.deviceName != null) {
      yield r'deviceName';
      yield serializers.serialize(
        object.deviceName,
        specifiedType: const FullType(String),
      );
    }
    if (object.deviceToken != null) {
      yield r'deviceToken';
      yield serializers.serialize(
        object.deviceToken,
        specifiedType: const FullType(String),
      );
    }
    if (object.displayName != null) {
      yield r'displayName';
      yield serializers.serialize(
        object.displayName,
        specifiedType: const FullType(String),
      );
    }
    if (object.failedPinAttempts != null) {
      yield r'failedPinAttempts';
      yield serializers.serialize(
        object.failedPinAttempts,
        specifiedType: const FullType(int),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.lockedUntil != null) {
      yield r'lockedUntil';
      yield serializers.serialize(
        object.lockedUntil,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(DeviceRegistrationCreatedResponseStatusEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DeviceRegistrationCreatedResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeviceRegistrationCreatedResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'approvedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.approvedAt = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'deviceModel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceModel = valueDes;
          break;
        case r'deviceName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceName = valueDes;
          break;
        case r'deviceToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceToken = valueDes;
          break;
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'failedPinAttempts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.failedPinAttempts = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'lockedUntil':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.lockedUntil = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeviceRegistrationCreatedResponseStatusEnum),
          ) as DeviceRegistrationCreatedResponseStatusEnum;
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
  DeviceRegistrationCreatedResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceRegistrationCreatedResponseBuilder();
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

class DeviceRegistrationCreatedResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PENDING')
  static const DeviceRegistrationCreatedResponseStatusEnum PENDING = _$deviceRegistrationCreatedResponseStatusEnum_PENDING;
  @BuiltValueEnumConst(wireName: r'APPROVED')
  static const DeviceRegistrationCreatedResponseStatusEnum APPROVED = _$deviceRegistrationCreatedResponseStatusEnum_APPROVED;
  @BuiltValueEnumConst(wireName: r'REJECTED')
  static const DeviceRegistrationCreatedResponseStatusEnum REJECTED = _$deviceRegistrationCreatedResponseStatusEnum_REJECTED;
  @BuiltValueEnumConst(wireName: r'REVOKED')
  static const DeviceRegistrationCreatedResponseStatusEnum REVOKED = _$deviceRegistrationCreatedResponseStatusEnum_REVOKED;

  static Serializer<DeviceRegistrationCreatedResponseStatusEnum> get serializer => _$deviceRegistrationCreatedResponseStatusEnumSerializer;

  const DeviceRegistrationCreatedResponseStatusEnum._(String name): super(name);

  static BuiltSet<DeviceRegistrationCreatedResponseStatusEnum> get values => _$deviceRegistrationCreatedResponseStatusEnumValues;
  static DeviceRegistrationCreatedResponseStatusEnum valueOf(String name) => _$deviceRegistrationCreatedResponseStatusEnumValueOf(name);
}
