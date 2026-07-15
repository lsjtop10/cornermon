// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_login_response.g.dart';

/// AdminLoginResponse
///
/// Properties:
/// * [accessToken] 
/// * [expiresInSeconds] 
/// * [refreshToken] 
@BuiltValue()
abstract class AdminLoginResponse implements Built<AdminLoginResponse, AdminLoginResponseBuilder> {
  @BuiltValueField(wireName: r'accessToken')
  String? get accessToken;

  @BuiltValueField(wireName: r'expiresInSeconds')
  int? get expiresInSeconds;

  @BuiltValueField(wireName: r'refreshToken')
  String? get refreshToken;

  AdminLoginResponse._();

  factory AdminLoginResponse([void updates(AdminLoginResponseBuilder b)]) = _$AdminLoginResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminLoginResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminLoginResponse> get serializer => _$AdminLoginResponseSerializer();
}

class _$AdminLoginResponseSerializer implements PrimitiveSerializer<AdminLoginResponse> {
  @override
  final Iterable<Type> types = const [AdminLoginResponse, _$AdminLoginResponse];

  @override
  final String wireName = r'AdminLoginResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminLoginResponse object, {
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
    if (object.refreshToken != null) {
      yield r'refreshToken';
      yield serializers.serialize(
        object.refreshToken,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminLoginResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminLoginResponseBuilder result,
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
        case r'refreshToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.refreshToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminLoginResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminLoginResponseBuilder();
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

