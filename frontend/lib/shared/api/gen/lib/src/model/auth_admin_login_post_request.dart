//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_admin_login_post_request.g.dart';

/// AuthAdminLoginPostRequest
///
/// Properties:
/// * [id] 
/// * [password] 
@BuiltValue()
abstract class AuthAdminLoginPostRequest implements Built<AuthAdminLoginPostRequest, AuthAdminLoginPostRequestBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'password')
  String get password;

  AuthAdminLoginPostRequest._();

  factory AuthAdminLoginPostRequest([void updates(AuthAdminLoginPostRequestBuilder b)]) = _$AuthAdminLoginPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthAdminLoginPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthAdminLoginPostRequest> get serializer => _$AuthAdminLoginPostRequestSerializer();
}

class _$AuthAdminLoginPostRequestSerializer implements PrimitiveSerializer<AuthAdminLoginPostRequest> {
  @override
  final Iterable<Type> types = const [AuthAdminLoginPostRequest, _$AuthAdminLoginPostRequest];

  @override
  final String wireName = r'AuthAdminLoginPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthAdminLoginPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'password';
    yield serializers.serialize(
      object.password,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthAdminLoginPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthAdminLoginPostRequestBuilder result,
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
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthAdminLoginPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthAdminLoginPostRequestBuilder();
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

