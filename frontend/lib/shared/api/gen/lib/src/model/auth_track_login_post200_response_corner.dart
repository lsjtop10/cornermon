//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_track_login_post200_response_corner.g.dart';

/// AuthTrackLoginPost200ResponseCorner
///
/// Properties:
/// * [id] 
/// * [name] 
@BuiltValue()
abstract class AuthTrackLoginPost200ResponseCorner implements Built<AuthTrackLoginPost200ResponseCorner, AuthTrackLoginPost200ResponseCornerBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'name')
  String? get name;

  AuthTrackLoginPost200ResponseCorner._();

  factory AuthTrackLoginPost200ResponseCorner([void updates(AuthTrackLoginPost200ResponseCornerBuilder b)]) = _$AuthTrackLoginPost200ResponseCorner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthTrackLoginPost200ResponseCornerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthTrackLoginPost200ResponseCorner> get serializer => _$AuthTrackLoginPost200ResponseCornerSerializer();
}

class _$AuthTrackLoginPost200ResponseCornerSerializer implements PrimitiveSerializer<AuthTrackLoginPost200ResponseCorner> {
  @override
  final Iterable<Type> types = const [AuthTrackLoginPost200ResponseCorner, _$AuthTrackLoginPost200ResponseCorner];

  @override
  final String wireName = r'AuthTrackLoginPost200ResponseCorner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthTrackLoginPost200ResponseCorner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthTrackLoginPost200ResponseCorner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthTrackLoginPost200ResponseCornerBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthTrackLoginPost200ResponseCorner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthTrackLoginPost200ResponseCornerBuilder();
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

