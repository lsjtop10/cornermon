//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'track_login_request.g.dart';

/// TrackLoginRequest
///
/// Properties:
/// * [pin] 
@BuiltValue()
abstract class TrackLoginRequest implements Built<TrackLoginRequest, TrackLoginRequestBuilder> {
  @BuiltValueField(wireName: r'pin')
  String? get pin;

  TrackLoginRequest._();

  factory TrackLoginRequest([void updates(TrackLoginRequestBuilder b)]) = _$TrackLoginRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackLoginRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackLoginRequest> get serializer => _$TrackLoginRequestSerializer();
}

class _$TrackLoginRequestSerializer implements PrimitiveSerializer<TrackLoginRequest> {
  @override
  final Iterable<Type> types = const [TrackLoginRequest, _$TrackLoginRequest];

  @override
  final String wireName = r'TrackLoginRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackLoginRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.pin != null) {
      yield r'pin';
      yield serializers.serialize(
        object.pin,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackLoginRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackLoginRequestBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackLoginRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackLoginRequestBuilder();
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

