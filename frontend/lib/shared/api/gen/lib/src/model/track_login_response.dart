// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/corner_response.dart';
import 'package:cornermon_api_gen/src/model/track_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'track_login_response.g.dart';

/// TrackLoginResponse
///
/// Properties:
/// * [corner] 
/// * [track] 
/// * [trackToken] 
@BuiltValue()
abstract class TrackLoginResponse implements Built<TrackLoginResponse, TrackLoginResponseBuilder> {
  @BuiltValueField(wireName: r'corner')
  CornerResponse? get corner;

  @BuiltValueField(wireName: r'track')
  TrackResponse? get track;

  @BuiltValueField(wireName: r'trackToken')
  String? get trackToken;

  TrackLoginResponse._();

  factory TrackLoginResponse([void updates(TrackLoginResponseBuilder b)]) = _$TrackLoginResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackLoginResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackLoginResponse> get serializer => _$TrackLoginResponseSerializer();
}

class _$TrackLoginResponseSerializer implements PrimitiveSerializer<TrackLoginResponse> {
  @override
  final Iterable<Type> types = const [TrackLoginResponse, _$TrackLoginResponse];

  @override
  final String wireName = r'TrackLoginResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackLoginResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.corner != null) {
      yield r'corner';
      yield serializers.serialize(
        object.corner,
        specifiedType: const FullType(CornerResponse),
      );
    }
    if (object.track != null) {
      yield r'track';
      yield serializers.serialize(
        object.track,
        specifiedType: const FullType(TrackResponse),
      );
    }
    if (object.trackToken != null) {
      yield r'trackToken';
      yield serializers.serialize(
        object.trackToken,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackLoginResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackLoginResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'corner':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CornerResponse),
          ) as CornerResponse;
          result.corner.replace(valueDes);
          break;
        case r'track':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TrackResponse),
          ) as TrackResponse;
          result.track.replace(valueDes);
          break;
        case r'trackToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.trackToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackLoginResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackLoginResponseBuilder();
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
