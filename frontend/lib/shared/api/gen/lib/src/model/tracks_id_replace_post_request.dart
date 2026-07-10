//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracks_id_replace_post_request.g.dart';

/// TracksIdReplacePostRequest
///
/// Properties:
/// * [newCornerId] - 교체될 신규 코너 ID
@BuiltValue()
abstract class TracksIdReplacePostRequest implements Built<TracksIdReplacePostRequest, TracksIdReplacePostRequestBuilder> {
  /// 교체될 신규 코너 ID
  @BuiltValueField(wireName: r'newCornerId')
  String get newCornerId;

  TracksIdReplacePostRequest._();

  factory TracksIdReplacePostRequest([void updates(TracksIdReplacePostRequestBuilder b)]) = _$TracksIdReplacePostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TracksIdReplacePostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TracksIdReplacePostRequest> get serializer => _$TracksIdReplacePostRequestSerializer();
}

class _$TracksIdReplacePostRequestSerializer implements PrimitiveSerializer<TracksIdReplacePostRequest> {
  @override
  final Iterable<Type> types = const [TracksIdReplacePostRequest, _$TracksIdReplacePostRequest];

  @override
  final String wireName = r'TracksIdReplacePostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TracksIdReplacePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'newCornerId';
    yield serializers.serialize(
      object.newCornerId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TracksIdReplacePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TracksIdReplacePostRequestBuilder result,
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
  TracksIdReplacePostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TracksIdReplacePostRequestBuilder();
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

