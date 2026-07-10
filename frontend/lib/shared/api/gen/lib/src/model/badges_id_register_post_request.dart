//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'badges_id_register_post_request.g.dart';

/// BadgesIdRegisterPostRequest
///
/// Properties:
/// * [groupName] - 조 이름 (예: 1조, 사랑조)
@BuiltValue()
abstract class BadgesIdRegisterPostRequest implements Built<BadgesIdRegisterPostRequest, BadgesIdRegisterPostRequestBuilder> {
  /// 조 이름 (예: 1조, 사랑조)
  @BuiltValueField(wireName: r'groupName')
  String get groupName;

  BadgesIdRegisterPostRequest._();

  factory BadgesIdRegisterPostRequest([void updates(BadgesIdRegisterPostRequestBuilder b)]) = _$BadgesIdRegisterPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BadgesIdRegisterPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BadgesIdRegisterPostRequest> get serializer => _$BadgesIdRegisterPostRequestSerializer();
}

class _$BadgesIdRegisterPostRequestSerializer implements PrimitiveSerializer<BadgesIdRegisterPostRequest> {
  @override
  final Iterable<Type> types = const [BadgesIdRegisterPostRequest, _$BadgesIdRegisterPostRequest];

  @override
  final String wireName = r'BadgesIdRegisterPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BadgesIdRegisterPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'groupName';
    yield serializers.serialize(
      object.groupName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BadgesIdRegisterPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BadgesIdRegisterPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'groupName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.groupName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BadgesIdRegisterPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BadgesIdRegisterPostRequestBuilder();
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

