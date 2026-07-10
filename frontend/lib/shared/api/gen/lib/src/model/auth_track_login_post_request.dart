//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_track_login_post_request.g.dart';

/// AuthTrackLoginPostRequest
///
/// Properties:
/// * [pin] - 6자리 숫자 트랙 PIN
@BuiltValue()
abstract class AuthTrackLoginPostRequest implements Built<AuthTrackLoginPostRequest, AuthTrackLoginPostRequestBuilder> {
  /// 6자리 숫자 트랙 PIN
  @BuiltValueField(wireName: r'pin')
  String get pin;

  AuthTrackLoginPostRequest._();

  factory AuthTrackLoginPostRequest([void updates(AuthTrackLoginPostRequestBuilder b)]) = _$AuthTrackLoginPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthTrackLoginPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthTrackLoginPostRequest> get serializer => _$AuthTrackLoginPostRequestSerializer();
}

class _$AuthTrackLoginPostRequestSerializer implements PrimitiveSerializer<AuthTrackLoginPostRequest> {
  @override
  final Iterable<Type> types = const [AuthTrackLoginPostRequest, _$AuthTrackLoginPostRequest];

  @override
  final String wireName = r'AuthTrackLoginPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthTrackLoginPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'pin';
    yield serializers.serialize(
      object.pin,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthTrackLoginPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthTrackLoginPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'pin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pin = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthTrackLoginPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthTrackLoginPostRequestBuilder();
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

