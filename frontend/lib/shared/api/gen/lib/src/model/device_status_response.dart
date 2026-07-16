//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_status_response.g.dart';

/// DeviceStatusResponse
///
/// Properties:
/// * [status] 
@BuiltValue()
abstract class DeviceStatusResponse implements Built<DeviceStatusResponse, DeviceStatusResponseBuilder> {
  @BuiltValueField(wireName: r'status')
  DeviceStatusResponseStatusEnum? get status;
  // enum statusEnum {  PENDING,  APPROVED,  REJECTED,  REVOKED,  };

  DeviceStatusResponse._();

  factory DeviceStatusResponse([void updates(DeviceStatusResponseBuilder b)]) = _$DeviceStatusResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceStatusResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeviceStatusResponse> get serializer => _$DeviceStatusResponseSerializer();
}

class _$DeviceStatusResponseSerializer implements PrimitiveSerializer<DeviceStatusResponse> {
  @override
  final Iterable<Type> types = const [DeviceStatusResponse, _$DeviceStatusResponse];

  @override
  final String wireName = r'DeviceStatusResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeviceStatusResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(DeviceStatusResponseStatusEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DeviceStatusResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeviceStatusResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeviceStatusResponseStatusEnum),
          ) as DeviceStatusResponseStatusEnum;
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
  DeviceStatusResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceStatusResponseBuilder();
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

class DeviceStatusResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PENDING')
  static const DeviceStatusResponseStatusEnum PENDING = _$deviceStatusResponseStatusEnum_PENDING;
  @BuiltValueEnumConst(wireName: r'APPROVED')
  static const DeviceStatusResponseStatusEnum APPROVED = _$deviceStatusResponseStatusEnum_APPROVED;
  @BuiltValueEnumConst(wireName: r'REJECTED')
  static const DeviceStatusResponseStatusEnum REJECTED = _$deviceStatusResponseStatusEnum_REJECTED;
  @BuiltValueEnumConst(wireName: r'REVOKED')
  static const DeviceStatusResponseStatusEnum REVOKED = _$deviceStatusResponseStatusEnum_REVOKED;

  static Serializer<DeviceStatusResponseStatusEnum> get serializer => _$deviceStatusResponseStatusEnumSerializer;

  const DeviceStatusResponseStatusEnum._(String name): super(name);

  static BuiltSet<DeviceStatusResponseStatusEnum> get values => _$deviceStatusResponseStatusEnumValues;
  static DeviceStatusResponseStatusEnum valueOf(String name) => _$deviceStatusResponseStatusEnumValueOf(name);
}

