//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'demo_device_registration_request.g.dart';

/// DemoDeviceRegistrationRequest
///
/// Properties:
/// * [deviceModel] 
/// * [deviceName] 
/// * [displayName] 
@BuiltValue()
abstract class DemoDeviceRegistrationRequest implements Built<DemoDeviceRegistrationRequest, DemoDeviceRegistrationRequestBuilder> {
  @BuiltValueField(wireName: r'deviceModel')
  String? get deviceModel;

  @BuiltValueField(wireName: r'deviceName')
  String? get deviceName;

  @BuiltValueField(wireName: r'displayName')
  String? get displayName;

  DemoDeviceRegistrationRequest._();

  factory DemoDeviceRegistrationRequest([void updates(DemoDeviceRegistrationRequestBuilder b)]) = _$DemoDeviceRegistrationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DemoDeviceRegistrationRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DemoDeviceRegistrationRequest> get serializer => _$DemoDeviceRegistrationRequestSerializer();
}

class _$DemoDeviceRegistrationRequestSerializer implements PrimitiveSerializer<DemoDeviceRegistrationRequest> {
  @override
  final Iterable<Type> types = const [DemoDeviceRegistrationRequest, _$DemoDeviceRegistrationRequest];

  @override
  final String wireName = r'DemoDeviceRegistrationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DemoDeviceRegistrationRequest object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    DemoDeviceRegistrationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DemoDeviceRegistrationRequestBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DemoDeviceRegistrationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DemoDeviceRegistrationRequestBuilder();
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

