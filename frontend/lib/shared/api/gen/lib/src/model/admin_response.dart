// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_response.g.dart';

/// AdminResponse
///
/// Properties:
/// * [id] 
/// * [role] 
/// * [username] 
@BuiltValue()
abstract class AdminResponse implements Built<AdminResponse, AdminResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'role')
  AdminResponseRoleEnum? get role;
  // enum roleEnum {  SYSTEM_ADMIN,  CORNER_OPERATOR,  };

  @BuiltValueField(wireName: r'username')
  String? get username;

  AdminResponse._();

  factory AdminResponse([void updates(AdminResponseBuilder b)]) = _$AdminResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminResponse> get serializer => _$AdminResponseSerializer();
}

class _$AdminResponseSerializer implements PrimitiveSerializer<AdminResponse> {
  @override
  final Iterable<Type> types = const [AdminResponse, _$AdminResponse];

  @override
  final String wireName = r'AdminResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.role != null) {
      yield r'role';
      yield serializers.serialize(
        object.role,
        specifiedType: const FullType(AdminResponseRoleEnum),
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
    AdminResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminResponseBuilder result,
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
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminResponseRoleEnum),
          ) as AdminResponseRoleEnum;
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
  AdminResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminResponseBuilder();
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

class AdminResponseRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SYSTEM_ADMIN')
  static const AdminResponseRoleEnum SYSTEM_ADMIN = _$adminResponseRoleEnum_SYSTEM_ADMIN;
  @BuiltValueEnumConst(wireName: r'CORNER_OPERATOR')
  static const AdminResponseRoleEnum CORNER_OPERATOR = _$adminResponseRoleEnum_CORNER_OPERATOR;

  static Serializer<AdminResponseRoleEnum> get serializer => _$adminResponseRoleEnumSerializer;

  const AdminResponseRoleEnum._(String name): super(name);

  static BuiltSet<AdminResponseRoleEnum> get values => _$adminResponseRoleEnumValues;
  static AdminResponseRoleEnum valueOf(String name) => _$adminResponseRoleEnumValueOf(name);
}

