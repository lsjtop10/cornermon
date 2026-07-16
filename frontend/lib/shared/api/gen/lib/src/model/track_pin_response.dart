// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/track_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'track_pin_response.g.dart';

/// TrackPinResponse
///
/// Properties:
/// * [pin] 
/// * [track] 
@BuiltValue()
abstract class TrackPinResponse implements Built<TrackPinResponse, TrackPinResponseBuilder> {
  @BuiltValueField(wireName: r'pin')
  String? get pin;

  @BuiltValueField(wireName: r'track')
  TrackResponse? get track;

  TrackPinResponse._();

  factory TrackPinResponse([void updates(TrackPinResponseBuilder b)]) = _$TrackPinResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackPinResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackPinResponse> get serializer => _$TrackPinResponseSerializer();
}

class _$TrackPinResponseSerializer implements PrimitiveSerializer<TrackPinResponse> {
  @override
  final Iterable<Type> types = const [TrackPinResponse, _$TrackPinResponse];

  @override
  final String wireName = r'TrackPinResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackPinResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.pin != null) {
      yield r'pin';
      yield serializers.serialize(
        object.pin,
        specifiedType: const FullType(String),
      );
    }
    if (object.track != null) {
      yield r'track';
      yield serializers.serialize(
        object.track,
        specifiedType: const FullType(TrackResponse),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackPinResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackPinResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'pin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pin = valueDes;
          break;
        case r'track':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TrackResponse),
          ) as TrackResponse;
          result.track.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackPinResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackPinResponseBuilder();
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
