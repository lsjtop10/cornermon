//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'badges_scan_register_post_request.g.dart';

/// BadgesScanRegisterPostRequest
///
/// Properties:
/// * [qrPayload] - QR 코드에서 스캔한 페이로드 값
/// * [groupName] 
@BuiltValue()
abstract class BadgesScanRegisterPostRequest implements Built<BadgesScanRegisterPostRequest, BadgesScanRegisterPostRequestBuilder> {
  /// QR 코드에서 스캔한 페이로드 값
  @BuiltValueField(wireName: r'qrPayload')
  String get qrPayload;

  @BuiltValueField(wireName: r'groupName')
  String get groupName;

  BadgesScanRegisterPostRequest._();

  factory BadgesScanRegisterPostRequest([void updates(BadgesScanRegisterPostRequestBuilder b)]) = _$BadgesScanRegisterPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BadgesScanRegisterPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BadgesScanRegisterPostRequest> get serializer => _$BadgesScanRegisterPostRequestSerializer();
}

class _$BadgesScanRegisterPostRequestSerializer implements PrimitiveSerializer<BadgesScanRegisterPostRequest> {
  @override
  final Iterable<Type> types = const [BadgesScanRegisterPostRequest, _$BadgesScanRegisterPostRequest];

  @override
  final String wireName = r'BadgesScanRegisterPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BadgesScanRegisterPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'qrPayload';
    yield serializers.serialize(
      object.qrPayload,
      specifiedType: const FullType(String),
    );
    yield r'groupName';
    yield serializers.serialize(
      object.groupName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BadgesScanRegisterPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BadgesScanRegisterPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'qrPayload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.qrPayload = valueDes;
          break;
        case r'groupName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.groupName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BadgesScanRegisterPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BadgesScanRegisterPostRequestBuilder();
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

