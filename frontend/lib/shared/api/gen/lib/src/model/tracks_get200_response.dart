//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/track.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracks_get200_response.g.dart';

/// TracksGet200Response
///
/// Properties:
/// * [tracks] 
@BuiltValue()
abstract class TracksGet200Response implements Built<TracksGet200Response, TracksGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'tracks')
  BuiltList<Track>? get tracks;

  TracksGet200Response._();

  factory TracksGet200Response([void updates(TracksGet200ResponseBuilder b)]) = _$TracksGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TracksGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TracksGet200Response> get serializer => _$TracksGet200ResponseSerializer();
}

class _$TracksGet200ResponseSerializer implements PrimitiveSerializer<TracksGet200Response> {
  @override
  final Iterable<Type> types = const [TracksGet200Response, _$TracksGet200Response];

  @override
  final String wireName = r'TracksGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TracksGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.tracks != null) {
      yield r'tracks';
      yield serializers.serialize(
        object.tracks,
        specifiedType: const FullType(BuiltList, [FullType(Track)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TracksGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TracksGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'tracks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Track)]),
          ) as BuiltList<Track>;
          result.tracks.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TracksGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TracksGet200ResponseBuilder();
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

