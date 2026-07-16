//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_camp_request.g.dart';

/// CreateCampRequest
///
/// Properties:
/// * [endAt] 
/// * [name] 
/// * [startAt] 
@BuiltValue()
abstract class CreateCampRequest implements Built<CreateCampRequest, CreateCampRequestBuilder> {
  @BuiltValueField(wireName: r'endAt')
  DateTime? get endAt;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'startAt')
  DateTime? get startAt;

  CreateCampRequest._();

  factory CreateCampRequest([void updates(CreateCampRequestBuilder b)]) = _$CreateCampRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateCampRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateCampRequest> get serializer => _$CreateCampRequestSerializer();
}

class _$CreateCampRequestSerializer implements PrimitiveSerializer<CreateCampRequest> {
  @override
  final Iterable<Type> types = const [CreateCampRequest, _$CreateCampRequest];

  @override
  final String wireName = r'CreateCampRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateCampRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.endAt != null) {
      yield r'endAt';
      yield serializers.serialize(
        object.endAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.startAt != null) {
      yield r'startAt';
      yield serializers.serialize(
        object.startAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateCampRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateCampRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'endAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.endAt = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'startAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateCampRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateCampRequestBuilder();
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

