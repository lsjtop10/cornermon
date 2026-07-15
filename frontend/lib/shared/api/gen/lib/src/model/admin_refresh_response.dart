// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_refresh_response.g.dart';

/// AdminRefreshResponse
///
/// Properties:
/// * [accessToken] 
/// * [expiresInSeconds] 
@BuiltValue()
abstract class AdminRefreshResponse implements Built<AdminRefreshResponse, AdminRefreshResponseBuilder> {
  @BuiltValueField(wireName: r'accessToken')
  String? get accessToken;

  @BuiltValueField(wireName: r'expiresInSeconds')
  int? get expiresInSeconds;

  AdminRefreshResponse._();

  factory AdminRefreshResponse([void updates(AdminRefreshResponseBuilder b)]) = _$AdminRefreshResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminRefreshResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminRefreshResponse> get serializer => _$AdminRefreshResponseSerializer();
}

class _$AdminRefreshResponseSerializer implements PrimitiveSerializer<AdminRefreshResponse> {
  @override
  final Iterable<Type> types = const [AdminRefreshResponse, _$AdminRefreshResponse];

  @override
  final String wireName = r'AdminRefreshResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminRefreshResponse object, {
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
    AdminRefreshResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminRefreshResponseBuilder result,
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
  AdminRefreshResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminRefreshResponseBuilder();
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
