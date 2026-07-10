//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/auth_track_login_post200_response_corner.dart';
import 'package:cornermon_api_gen/src/model/track.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_track_login_post200_response.g.dart';

/// AuthTrackLoginPost200Response
///
/// Properties:
/// * [trackToken] - 트랙 세션 불투명 토큰
/// * [track] 
/// * [corner] 
@BuiltValue()
abstract class AuthTrackLoginPost200Response implements Built<AuthTrackLoginPost200Response, AuthTrackLoginPost200ResponseBuilder> {
  /// 트랙 세션 불투명 토큰
  @BuiltValueField(wireName: r'trackToken')
  String? get trackToken;

  @BuiltValueField(wireName: r'track')
  Track? get track;

  @BuiltValueField(wireName: r'corner')
  AuthTrackLoginPost200ResponseCorner? get corner;

  AuthTrackLoginPost200Response._();

  factory AuthTrackLoginPost200Response([void updates(AuthTrackLoginPost200ResponseBuilder b)]) = _$AuthTrackLoginPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthTrackLoginPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthTrackLoginPost200Response> get serializer => _$AuthTrackLoginPost200ResponseSerializer();
}

class _$AuthTrackLoginPost200ResponseSerializer implements PrimitiveSerializer<AuthTrackLoginPost200Response> {
  @override
  final Iterable<Type> types = const [AuthTrackLoginPost200Response, _$AuthTrackLoginPost200Response];

  @override
  final String wireName = r'AuthTrackLoginPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthTrackLoginPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.trackToken != null) {
      yield r'trackToken';
      yield serializers.serialize(
        object.trackToken,
        specifiedType: const FullType(String),
      );
    }
    if (object.track != null) {
      yield r'track';
      yield serializers.serialize(
        object.track,
        specifiedType: const FullType(Track),
      );
    }
    if (object.corner != null) {
      yield r'corner';
      yield serializers.serialize(
        object.corner,
        specifiedType: const FullType(AuthTrackLoginPost200ResponseCorner),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthTrackLoginPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthTrackLoginPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'trackToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.trackToken = valueDes;
          break;
        case r'track':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Track),
          ) as Track;
          result.track.replace(valueDes);
          break;
        case r'corner':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AuthTrackLoginPost200ResponseCorner),
          ) as AuthTrackLoginPost200ResponseCorner;
          result.corner.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthTrackLoginPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthTrackLoginPost200ResponseBuilder();
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

