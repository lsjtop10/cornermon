// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_tracks_request.g.dart';

/// CreateTracksRequest
///
/// Properties:
/// * [campId] 
/// * [cornerId] 
/// * [count] 
@BuiltValue()
abstract class CreateTracksRequest implements Built<CreateTracksRequest, CreateTracksRequestBuilder> {
  @BuiltValueField(wireName: r'campId')
  String? get campId;

  @BuiltValueField(wireName: r'cornerId')
  String? get cornerId;

  @BuiltValueField(wireName: r'count')
  int? get count;

  CreateTracksRequest._();

  factory CreateTracksRequest([void updates(CreateTracksRequestBuilder b)]) = _$CreateTracksRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateTracksRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateTracksRequest> get serializer => _$CreateTracksRequestSerializer();
}

class _$CreateTracksRequestSerializer implements PrimitiveSerializer<CreateTracksRequest> {
  @override
  final Iterable<Type> types = const [CreateTracksRequest, _$CreateTracksRequest];

  @override
  final String wireName = r'CreateTracksRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateTracksRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.campId != null) {
      yield r'campId';
      yield serializers.serialize(
        object.campId,
        specifiedType: const FullType(String),
      );
    }
    if (object.cornerId != null) {
      yield r'cornerId';
      yield serializers.serialize(
        object.cornerId,
        specifiedType: const FullType(String),
      );
    }
    if (object.count != null) {
      yield r'count';
      yield serializers.serialize(
        object.count,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateTracksRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateTracksRequestBuilder result,
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
        case r'cornerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cornerId = valueDes;
          break;
        case r'count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.count = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateTracksRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateTracksRequestBuilder();
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

