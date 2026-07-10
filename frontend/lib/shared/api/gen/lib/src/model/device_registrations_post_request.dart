//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_registrations_post_request.g.dart';

/// DeviceRegistrationsPostRequest
///
/// Properties:
/// * [registrationCode] - 관리자가 공유한 등록 코드
/// * [deviceName] - 기기 식별 이름
@BuiltValue()
abstract class DeviceRegistrationsPostRequest implements Built<DeviceRegistrationsPostRequest, DeviceRegistrationsPostRequestBuilder> {
  /// 관리자가 공유한 등록 코드
  @BuiltValueField(wireName: r'registrationCode')
  String get registrationCode;

  /// 기기 식별 이름
  @BuiltValueField(wireName: r'deviceName')
  String get deviceName;

  DeviceRegistrationsPostRequest._();

  factory DeviceRegistrationsPostRequest([void updates(DeviceRegistrationsPostRequestBuilder b)]) = _$DeviceRegistrationsPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceRegistrationsPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeviceRegistrationsPostRequest> get serializer => _$DeviceRegistrationsPostRequestSerializer();
}

class _$DeviceRegistrationsPostRequestSerializer implements PrimitiveSerializer<DeviceRegistrationsPostRequest> {
  @override
  final Iterable<Type> types = const [DeviceRegistrationsPostRequest, _$DeviceRegistrationsPostRequest];

  @override
  final String wireName = r'DeviceRegistrationsPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeviceRegistrationsPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'registrationCode';
    yield serializers.serialize(
      object.registrationCode,
      specifiedType: const FullType(String),
    );
    yield r'deviceName';
    yield serializers.serialize(
      object.deviceName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeviceRegistrationsPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeviceRegistrationsPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'registrationCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.registrationCode = valueDes;
          break;
        case r'deviceName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeviceRegistrationsPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceRegistrationsPostRequestBuilder();
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

