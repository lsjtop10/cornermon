// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_login_request.g.dart';

/// AdminLoginRequest
///
/// Properties:
/// * [id] 
/// * [password] 
@BuiltValue()
abstract class AdminLoginRequest implements Built<AdminLoginRequest, AdminLoginRequestBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'password')
  String? get password;

  AdminLoginRequest._();

  factory AdminLoginRequest([void updates(AdminLoginRequestBuilder b)]) = _$AdminLoginRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminLoginRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminLoginRequest> get serializer => _$AdminLoginRequestSerializer();
}

class _$AdminLoginRequestSerializer implements PrimitiveSerializer<AdminLoginRequest> {
  @override
  final Iterable<Type> types = const [AdminLoginRequest, _$AdminLoginRequest];

  @override
  final String wireName = r'AdminLoginRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminLoginRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.password != null) {
      yield r'password';
      yield serializers.serialize(
        object.password,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminLoginRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminLoginRequestBuilder result,
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
  AdminLoginRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminLoginRequestBuilder();
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
