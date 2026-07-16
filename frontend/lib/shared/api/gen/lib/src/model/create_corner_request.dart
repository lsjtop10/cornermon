//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_corner_request.g.dart';

/// CreateCornerRequest
///
/// Properties:
/// * [campId] 
/// * [name] 
/// * [targetMinutes] 
@BuiltValue()
abstract class CreateCornerRequest implements Built<CreateCornerRequest, CreateCornerRequestBuilder> {
  @BuiltValueField(wireName: r'campId')
  String? get campId;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'targetMinutes')
  int? get targetMinutes;

  CreateCornerRequest._();

  factory CreateCornerRequest([void updates(CreateCornerRequestBuilder b)]) = _$CreateCornerRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateCornerRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateCornerRequest> get serializer => _$CreateCornerRequestSerializer();
}

class _$CreateCornerRequestSerializer implements PrimitiveSerializer<CreateCornerRequest> {
  @override
  final Iterable<Type> types = const [CreateCornerRequest, _$CreateCornerRequest];

  @override
  final String wireName = r'CreateCornerRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateCornerRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.campId != null) {
      yield r'campId';
      yield serializers.serialize(
        object.campId,
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
    if (object.targetMinutes != null) {
      yield r'targetMinutes';
      yield serializers.serialize(
        object.targetMinutes,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateCornerRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateCornerRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'campId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.campId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'targetMinutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.targetMinutes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateCornerRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateCornerRequestBuilder();
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

