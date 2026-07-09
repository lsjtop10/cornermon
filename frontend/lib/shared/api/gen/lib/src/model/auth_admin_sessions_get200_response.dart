//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/admin_session.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_admin_sessions_get200_response.g.dart';

/// AuthAdminSessionsGet200Response
///
/// Properties:
/// * [sessions] 
@BuiltValue()
abstract class AuthAdminSessionsGet200Response implements Built<AuthAdminSessionsGet200Response, AuthAdminSessionsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'sessions')
  BuiltList<AdminSession>? get sessions;

  AuthAdminSessionsGet200Response._();

  factory AuthAdminSessionsGet200Response([void updates(AuthAdminSessionsGet200ResponseBuilder b)]) = _$AuthAdminSessionsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthAdminSessionsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthAdminSessionsGet200Response> get serializer => _$AuthAdminSessionsGet200ResponseSerializer();
}

class _$AuthAdminSessionsGet200ResponseSerializer implements PrimitiveSerializer<AuthAdminSessionsGet200Response> {
  @override
  final Iterable<Type> types = const [AuthAdminSessionsGet200Response, _$AuthAdminSessionsGet200Response];

  @override
  final String wireName = r'AuthAdminSessionsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthAdminSessionsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.sessions != null) {
      yield r'sessions';
      yield serializers.serialize(
        object.sessions,
        specifiedType: const FullType(BuiltList, [FullType(AdminSession)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthAdminSessionsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthAdminSessionsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sessions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminSession)]),
          ) as BuiltList<AdminSession>;
          result.sessions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthAdminSessionsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthAdminSessionsGet200ResponseBuilder();
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

