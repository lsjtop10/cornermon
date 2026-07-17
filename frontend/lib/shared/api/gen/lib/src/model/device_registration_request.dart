// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_registration_request.g.dart';

/// DeviceRegistrationRequest
///
/// Properties:
/// * [deviceModel] 
/// * [deviceName] 
/// * [displayName] 
/// * [registrationCode] 
/// * [role] 
@BuiltValue()
abstract class DeviceRegistrationRequest implements Built<DeviceRegistrationRequest, DeviceRegistrationRequestBuilder> {
  @BuiltValueField(wireName: r'deviceModel')
  String? get deviceModel;

  @BuiltValueField(wireName: r'deviceName')
  String? get deviceName;

  @BuiltValueField(wireName: r'displayName')
  String? get displayName;

  @BuiltValueField(wireName: r'registrationCode')
  String? get registrationCode;

  @BuiltValueField(wireName: r'role')
  DeviceRegistrationRequestRoleEnum? get role;
  // enum roleEnum {  ADMIN,  FACILITATOR,  };

  DeviceRegistrationRequest._();

  factory DeviceRegistrationRequest([void updates(DeviceRegistrationRequestBuilder b)]) = _$DeviceRegistrationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceRegistrationRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeviceRegistrationRequest> get serializer => _$DeviceRegistrationRequestSerializer();
}

class _$DeviceRegistrationRequestSerializer implements PrimitiveSerializer<DeviceRegistrationRequest> {
  @override
  final Iterable<Type> types = const [DeviceRegistrationRequest, _$DeviceRegistrationRequest];

  @override
  final String wireName = r'DeviceRegistrationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeviceRegistrationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    if (object.displayName != null) {
      yield r'displayName';
      yield serializers.serialize(
        object.displayName,
        specifiedType: const FullType(String),
      );
    }
    if (object.registrationCode != null) {
      yield r'registrationCode';
      yield serializers.serialize(
        object.registrationCode,
        specifiedType: const FullType(String),
      );
    }
    if (object.role != null) {
      yield r'role';
      yield serializers.serialize(
        object.role,
        specifiedType: const FullType(DeviceRegistrationRequestRoleEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DeviceRegistrationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeviceRegistrationRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'registrationCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.registrationCode = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeviceRegistrationRequestRoleEnum),
          ) as DeviceRegistrationRequestRoleEnum;
          result.role = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeviceRegistrationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceRegistrationRequestBuilder();
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

class DeviceRegistrationRequestRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const DeviceRegistrationRequestRoleEnum ADMIN = _$deviceRegistrationRequestRoleEnum_ADMIN;
  @BuiltValueEnumConst(wireName: r'FACILITATOR')
  static const DeviceRegistrationRequestRoleEnum FACILITATOR = _$deviceRegistrationRequestRoleEnum_FACILITATOR;

  static Serializer<DeviceRegistrationRequestRoleEnum> get serializer => _$deviceRegistrationRequestRoleEnumSerializer;

  const DeviceRegistrationRequestRoleEnum._(String name): super(name);

  static BuiltSet<DeviceRegistrationRequestRoleEnum> get values => _$deviceRegistrationRequestRoleEnumValues;
  static DeviceRegistrationRequestRoleEnum valueOf(String name) => _$deviceRegistrationRequestRoleEnumValueOf(name);
}
