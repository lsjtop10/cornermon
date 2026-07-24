// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/error_code.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'error_response.g.dart';

/// ErrorResponse
///
/// Properties:
/// * [code] 
/// * [details] 
/// * [message] 
@BuiltValue()
abstract class ErrorResponse implements Built<ErrorResponse, ErrorResponseBuilder> {
  @BuiltValueField(wireName: r'code')
  ErrorCode? get code;
  // enum codeEnum {  BADGE_ALREADY_ASSIGNED,  BADGE_NOT_ASSIGNED,  BADGE_NOT_FOUND,  BAD_REQUEST,  CAMP_INVALID_SETTINGS,  CAMP_NOT_ACTIVE,  CAMP_NOT_AVAILABLE,  CAMP_NOT_ENDED,  CAMP_NOT_FOUND,  CAMP_SETTINGS_LOCKED,  CAMP_STATE_CONFLICT,  CONFLICT,  CORNER_NOT_FOUND,  DEVICE_INVALID_TRANSITION,  DEVICE_LOCKED,  DEVICE_NOT_APPROVED,  FORBIDDEN,  GROUP_NOT_FOUND,  HTTP_ERROR,  INTERNAL_ERROR,  INTERNAL_SERVER_ERROR,  INVALID_PIN,  INVALID_TRANSITION,  ITINERARY_CONFLICT,  NOT_FOUND,  SESSION_MIGRATION_REQUIRED,  SESSION_REVOKED,  TRACK_BUSY,  TRACK_CONFLICT,  TRACK_NOT_ACTIVE,  TRACK_NOT_BUSY,  TRACK_NOT_FOUND,  TRACK_SCOPE_FORBIDDEN,  UNAUTHORIZED,  };

  @BuiltValueField(wireName: r'details')
  BuiltMap<String, JsonObject?>? get details;

  @BuiltValueField(wireName: r'message')
  String? get message;

  ErrorResponse._();

  factory ErrorResponse([void updates(ErrorResponseBuilder b)]) = _$ErrorResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ErrorResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ErrorResponse> get serializer => _$ErrorResponseSerializer();
}

class _$ErrorResponseSerializer implements PrimitiveSerializer<ErrorResponse> {
  @override
  final Iterable<Type> types = const [ErrorResponse, _$ErrorResponse];

  @override
  final String wireName = r'ErrorResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ErrorResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.code != null) {
      yield r'code';
      yield serializers.serialize(
        object.code,
        specifiedType: const FullType(ErrorCode),
      );
    }
    if (object.details != null) {
      yield r'details';
      yield serializers.serialize(
        object.details,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.message != null) {
      yield r'message';
      yield serializers.serialize(
        object.message,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ErrorResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ErrorResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ErrorCode),
          ) as ErrorCode;
          result.code = valueDes;
          break;
        case r'details':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.details.replace(valueDes);
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ErrorResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ErrorResponseBuilder();
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
