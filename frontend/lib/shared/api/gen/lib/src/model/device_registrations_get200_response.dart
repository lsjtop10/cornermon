//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/device_registration.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_registrations_get200_response.g.dart';

/// DeviceRegistrationsGet200Response
///
/// Properties:
/// * [deviceRegistrations] 
@BuiltValue()
abstract class DeviceRegistrationsGet200Response implements Built<DeviceRegistrationsGet200Response, DeviceRegistrationsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'deviceRegistrations')
  BuiltList<DeviceRegistration>? get deviceRegistrations;

  DeviceRegistrationsGet200Response._();

  factory DeviceRegistrationsGet200Response([void updates(DeviceRegistrationsGet200ResponseBuilder b)]) = _$DeviceRegistrationsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceRegistrationsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeviceRegistrationsGet200Response> get serializer => _$DeviceRegistrationsGet200ResponseSerializer();
}

class _$DeviceRegistrationsGet200ResponseSerializer implements PrimitiveSerializer<DeviceRegistrationsGet200Response> {
  @override
  final Iterable<Type> types = const [DeviceRegistrationsGet200Response, _$DeviceRegistrationsGet200Response];

  @override
  final String wireName = r'DeviceRegistrationsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeviceRegistrationsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.deviceRegistrations != null) {
      yield r'deviceRegistrations';
      yield serializers.serialize(
        object.deviceRegistrations,
        specifiedType: const FullType(BuiltList, [FullType(DeviceRegistration)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DeviceRegistrationsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeviceRegistrationsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'deviceRegistrations':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(DeviceRegistration)]),
          ) as BuiltList<DeviceRegistration>;
          result.deviceRegistrations.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeviceRegistrationsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceRegistrationsGet200ResponseBuilder();
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

