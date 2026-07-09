//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/device_registration.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_registrations_post201_response.g.dart';

/// DeviceRegistrationsPost201Response
///
/// Properties:
/// * [deviceRegistration] 
/// * [deviceToken] - PENDING 상태의 불투명 기기 신뢰 토큰 (이후 Bearer로 전송)
@BuiltValue()
abstract class DeviceRegistrationsPost201Response implements Built<DeviceRegistrationsPost201Response, DeviceRegistrationsPost201ResponseBuilder> {
  @BuiltValueField(wireName: r'deviceRegistration')
  DeviceRegistration? get deviceRegistration;

  /// PENDING 상태의 불투명 기기 신뢰 토큰 (이후 Bearer로 전송)
  @BuiltValueField(wireName: r'deviceToken')
  String? get deviceToken;

  DeviceRegistrationsPost201Response._();

  factory DeviceRegistrationsPost201Response([void updates(DeviceRegistrationsPost201ResponseBuilder b)]) = _$DeviceRegistrationsPost201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceRegistrationsPost201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeviceRegistrationsPost201Response> get serializer => _$DeviceRegistrationsPost201ResponseSerializer();
}

class _$DeviceRegistrationsPost201ResponseSerializer implements PrimitiveSerializer<DeviceRegistrationsPost201Response> {
  @override
  final Iterable<Type> types = const [DeviceRegistrationsPost201Response, _$DeviceRegistrationsPost201Response];

  @override
  final String wireName = r'DeviceRegistrationsPost201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeviceRegistrationsPost201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.deviceRegistration != null) {
      yield r'deviceRegistration';
      yield serializers.serialize(
        object.deviceRegistration,
        specifiedType: const FullType(DeviceRegistration),
      );
    }
    if (object.deviceToken != null) {
      yield r'deviceToken';
      yield serializers.serialize(
        object.deviceToken,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DeviceRegistrationsPost201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeviceRegistrationsPost201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'deviceRegistration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeviceRegistration),
          ) as DeviceRegistration;
          result.deviceRegistration.replace(valueDes);
          break;
        case r'deviceToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeviceRegistrationsPost201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceRegistrationsPost201ResponseBuilder();
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

