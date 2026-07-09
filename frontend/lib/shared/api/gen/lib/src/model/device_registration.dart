//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/device_registration_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_registration.g.dart';

/// DeviceRegistration
///
/// Properties:
/// * [id] 
/// * [deviceName] - 기기 식별 이름 (등록 시 제출)
/// * [status] 
/// * [createdAt] 
/// * [approvedAt] 
@BuiltValue()
abstract class DeviceRegistration implements Built<DeviceRegistration, DeviceRegistrationBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  /// 기기 식별 이름 (등록 시 제출)
  @BuiltValueField(wireName: r'deviceName')
  String get deviceName;

  @BuiltValueField(wireName: r'status')
  DeviceRegistrationStatus get status;
  // enum statusEnum {  PENDING,  APPROVED,  REJECTED,  REVOKED,  };

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'approvedAt')
  DateTime? get approvedAt;

  DeviceRegistration._();

  factory DeviceRegistration([void updates(DeviceRegistrationBuilder b)]) = _$DeviceRegistration;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceRegistrationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeviceRegistration> get serializer => _$DeviceRegistrationSerializer();
}

class _$DeviceRegistrationSerializer implements PrimitiveSerializer<DeviceRegistration> {
  @override
  final Iterable<Type> types = const [DeviceRegistration, _$DeviceRegistration];

  @override
  final String wireName = r'DeviceRegistration';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeviceRegistration object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'deviceName';
    yield serializers.serialize(
      object.deviceName,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(DeviceRegistrationStatus),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.approvedAt != null) {
      yield r'approvedAt';
      yield serializers.serialize(
        object.approvedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DeviceRegistration object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeviceRegistrationBuilder result,
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
        case r'deviceName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceName = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeviceRegistrationStatus),
          ) as DeviceRegistrationStatus;
          result.status = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'approvedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.approvedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeviceRegistration deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceRegistrationBuilder();
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

