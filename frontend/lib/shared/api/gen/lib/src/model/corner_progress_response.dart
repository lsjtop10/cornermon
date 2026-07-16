// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'corner_progress_response.g.dart';

/// CornerProgressResponse
///
/// Properties:
/// * [cornerId] 
/// * [cornerName] 
/// * [status] 
@BuiltValue()
abstract class CornerProgressResponse implements Built<CornerProgressResponse, CornerProgressResponseBuilder> {
  @BuiltValueField(wireName: r'cornerId')
  String? get cornerId;

  @BuiltValueField(wireName: r'cornerName')
  String? get cornerName;

  @BuiltValueField(wireName: r'status')
  CornerProgressResponseStatusEnum? get status;
  // enum statusEnum {  NOT_VISITED,  IN_PROGRESS,  COMPLETED,  };

  CornerProgressResponse._();

  factory CornerProgressResponse([void updates(CornerProgressResponseBuilder b)]) = _$CornerProgressResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CornerProgressResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CornerProgressResponse> get serializer => _$CornerProgressResponseSerializer();
}

class _$CornerProgressResponseSerializer implements PrimitiveSerializer<CornerProgressResponse> {
  @override
  final Iterable<Type> types = const [CornerProgressResponse, _$CornerProgressResponse];

  @override
  final String wireName = r'CornerProgressResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CornerProgressResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.cornerId != null) {
      yield r'cornerId';
      yield serializers.serialize(
        object.cornerId,
        specifiedType: const FullType(String),
      );
    }
    if (object.cornerName != null) {
      yield r'cornerName';
      yield serializers.serialize(
        object.cornerName,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(CornerProgressResponseStatusEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CornerProgressResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CornerProgressResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'cornerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cornerId = valueDes;
          break;
        case r'cornerName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cornerName = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CornerProgressResponseStatusEnum),
          ) as CornerProgressResponseStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CornerProgressResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CornerProgressResponseBuilder();
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

class CornerProgressResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'NOT_VISITED')
  static const CornerProgressResponseStatusEnum NOT_VISITED = _$cornerProgressResponseStatusEnum_NOT_VISITED;
  @BuiltValueEnumConst(wireName: r'IN_PROGRESS')
  static const CornerProgressResponseStatusEnum IN_PROGRESS = _$cornerProgressResponseStatusEnum_IN_PROGRESS;
  @BuiltValueEnumConst(wireName: r'COMPLETED')
  static const CornerProgressResponseStatusEnum COMPLETED = _$cornerProgressResponseStatusEnum_COMPLETED;

  static Serializer<CornerProgressResponseStatusEnum> get serializer => _$cornerProgressResponseStatusEnumSerializer;

  const CornerProgressResponseStatusEnum._(String name): super(name);

  static BuiltSet<CornerProgressResponseStatusEnum> get values => _$cornerProgressResponseStatusEnumValues;
  static CornerProgressResponseStatusEnum valueOf(String name) => _$cornerProgressResponseStatusEnumValueOf(name);
}

