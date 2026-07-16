// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_admin_request.g.dart';

/// CreateAdminRequest
///
/// Properties:
/// * [password] 
/// * [role] 
/// * [username] 
@BuiltValue()
abstract class CreateAdminRequest implements Built<CreateAdminRequest, CreateAdminRequestBuilder> {
  @BuiltValueField(wireName: r'password')
  String? get password;

  @BuiltValueField(wireName: r'role')
  CreateAdminRequestRoleEnum? get role;
  // enum roleEnum {  CORNER_OPERATOR,  };

  @BuiltValueField(wireName: r'username')
  String? get username;

  CreateAdminRequest._();

  factory CreateAdminRequest([void updates(CreateAdminRequestBuilder b)]) = _$CreateAdminRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateAdminRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateAdminRequest> get serializer => _$CreateAdminRequestSerializer();
}

class _$CreateAdminRequestSerializer implements PrimitiveSerializer<CreateAdminRequest> {
  @override
  final Iterable<Type> types = const [CreateAdminRequest, _$CreateAdminRequest];

  @override
  final String wireName = r'CreateAdminRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateAdminRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.password != null) {
      yield r'password';
      yield serializers.serialize(
        object.password,
        specifiedType: const FullType(String),
      );
    }
    if (object.role != null) {
      yield r'role';
      yield serializers.serialize(
        object.role,
        specifiedType: const FullType(CreateAdminRequestRoleEnum),
      );
    }
    if (object.username != null) {
      yield r'username';
      yield serializers.serialize(
        object.username,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateAdminRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateAdminRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateAdminRequestRoleEnum),
          ) as CreateAdminRequestRoleEnum;
          result.role = valueDes;
          break;
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateAdminRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateAdminRequestBuilder();
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

class CreateAdminRequestRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'CORNER_OPERATOR')
  static const CreateAdminRequestRoleEnum CORNER_OPERATOR = _$createAdminRequestRoleEnum_CORNER_OPERATOR;

  static Serializer<CreateAdminRequestRoleEnum> get serializer => _$createAdminRequestRoleEnumSerializer;

  const CreateAdminRequestRoleEnum._(String name): super(name);

  static BuiltSet<CreateAdminRequestRoleEnum> get values => _$createAdminRequestRoleEnumValues;
  static CreateAdminRequestRoleEnum valueOf(String name) => _$createAdminRequestRoleEnumValueOf(name);
}

