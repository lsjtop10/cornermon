//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_admin_refresh_post200_response.g.dart';

/// AuthAdminRefreshPost200Response
///
/// Properties:
/// * [accessToken] 
/// * [expiresInSeconds] 
@BuiltValue()
abstract class AuthAdminRefreshPost200Response implements Built<AuthAdminRefreshPost200Response, AuthAdminRefreshPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'accessToken')
  String? get accessToken;

  @BuiltValueField(wireName: r'expiresInSeconds')
  int? get expiresInSeconds;

  AuthAdminRefreshPost200Response._();

  factory AuthAdminRefreshPost200Response([void updates(AuthAdminRefreshPost200ResponseBuilder b)]) = _$AuthAdminRefreshPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthAdminRefreshPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthAdminRefreshPost200Response> get serializer => _$AuthAdminRefreshPost200ResponseSerializer();
}

class _$AuthAdminRefreshPost200ResponseSerializer implements PrimitiveSerializer<AuthAdminRefreshPost200Response> {
  @override
  final Iterable<Type> types = const [AuthAdminRefreshPost200Response, _$AuthAdminRefreshPost200Response];

  @override
  final String wireName = r'AuthAdminRefreshPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthAdminRefreshPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.accessToken != null) {
      yield r'accessToken';
      yield serializers.serialize(
        object.accessToken,
        specifiedType: const FullType(String),
      );
    }
    if (object.expiresInSeconds != null) {
      yield r'expiresInSeconds';
      yield serializers.serialize(
        object.expiresInSeconds,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthAdminRefreshPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthAdminRefreshPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'accessToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accessToken = valueDes;
          break;
        case r'expiresInSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expiresInSeconds = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthAdminRefreshPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthAdminRefreshPost200ResponseBuilder();
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

