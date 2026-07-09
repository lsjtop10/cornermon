//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/badge.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'badges_get200_response.g.dart';

/// BadgesGet200Response
///
/// Properties:
/// * [badges] 
@BuiltValue()
abstract class BadgesGet200Response implements Built<BadgesGet200Response, BadgesGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'badges')
  BuiltList<Badge>? get badges;

  BadgesGet200Response._();

  factory BadgesGet200Response([void updates(BadgesGet200ResponseBuilder b)]) = _$BadgesGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BadgesGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BadgesGet200Response> get serializer => _$BadgesGet200ResponseSerializer();
}

class _$BadgesGet200ResponseSerializer implements PrimitiveSerializer<BadgesGet200Response> {
  @override
  final Iterable<Type> types = const [BadgesGet200Response, _$BadgesGet200Response];

  @override
  final String wireName = r'BadgesGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BadgesGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.badges != null) {
      yield r'badges';
      yield serializers.serialize(
        object.badges,
        specifiedType: const FullType(BuiltList, [FullType(Badge)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BadgesGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BadgesGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'badges':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Badge)]),
          ) as BuiltList<Badge>;
          result.badges.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BadgesGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BadgesGet200ResponseBuilder();
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

