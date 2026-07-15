// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'replace_track_request.g.dart';

/// ReplaceTrackRequest
///
/// Properties:
/// * [newCornerId] 
@BuiltValue()
abstract class ReplaceTrackRequest implements Built<ReplaceTrackRequest, ReplaceTrackRequestBuilder> {
  @BuiltValueField(wireName: r'newCornerId')
  String? get newCornerId;

  ReplaceTrackRequest._();

  factory ReplaceTrackRequest([void updates(ReplaceTrackRequestBuilder b)]) = _$ReplaceTrackRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReplaceTrackRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReplaceTrackRequest> get serializer => _$ReplaceTrackRequestSerializer();
}

class _$ReplaceTrackRequestSerializer implements PrimitiveSerializer<ReplaceTrackRequest> {
  @override
  final Iterable<Type> types = const [ReplaceTrackRequest, _$ReplaceTrackRequest];

  @override
  final String wireName = r'ReplaceTrackRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReplaceTrackRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.newCornerId != null) {
      yield r'newCornerId';
      yield serializers.serialize(
        object.newCornerId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ReplaceTrackRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReplaceTrackRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'newCornerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.newCornerId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReplaceTrackRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReplaceTrackRequestBuilder();
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
