// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'change_admin_password_request.g.dart';

/// ChangeAdminPasswordRequest
///
/// Properties:
/// * [password] 
@BuiltValue()
abstract class ChangeAdminPasswordRequest implements Built<ChangeAdminPasswordRequest, ChangeAdminPasswordRequestBuilder> {
  @BuiltValueField(wireName: r'password')
  String? get password;

  ChangeAdminPasswordRequest._();

  factory ChangeAdminPasswordRequest([void updates(ChangeAdminPasswordRequestBuilder b)]) = _$ChangeAdminPasswordRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChangeAdminPasswordRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChangeAdminPasswordRequest> get serializer => _$ChangeAdminPasswordRequestSerializer();
}

class _$ChangeAdminPasswordRequestSerializer implements PrimitiveSerializer<ChangeAdminPasswordRequest> {
  @override
  final Iterable<Type> types = const [ChangeAdminPasswordRequest, _$ChangeAdminPasswordRequest];

  @override
  final String wireName = r'ChangeAdminPasswordRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChangeAdminPasswordRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    ChangeAdminPasswordRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChangeAdminPasswordRequestBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChangeAdminPasswordRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChangeAdminPasswordRequestBuilder();
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
