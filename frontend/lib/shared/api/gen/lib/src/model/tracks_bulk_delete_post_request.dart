//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracks_bulk_delete_post_request.g.dart';

/// TracksBulkDeletePostRequest
///
/// Properties:
/// * [trackIds] 
@BuiltValue()
abstract class TracksBulkDeletePostRequest implements Built<TracksBulkDeletePostRequest, TracksBulkDeletePostRequestBuilder> {
  @BuiltValueField(wireName: r'trackIds')
  BuiltList<String> get trackIds;

  TracksBulkDeletePostRequest._();

  factory TracksBulkDeletePostRequest([void updates(TracksBulkDeletePostRequestBuilder b)]) = _$TracksBulkDeletePostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TracksBulkDeletePostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TracksBulkDeletePostRequest> get serializer => _$TracksBulkDeletePostRequestSerializer();
}

class _$TracksBulkDeletePostRequestSerializer implements PrimitiveSerializer<TracksBulkDeletePostRequest> {
  @override
  final Iterable<Type> types = const [TracksBulkDeletePostRequest, _$TracksBulkDeletePostRequest];

  @override
  final String wireName = r'TracksBulkDeletePostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TracksBulkDeletePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'trackIds';
    yield serializers.serialize(
      object.trackIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TracksBulkDeletePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TracksBulkDeletePostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'trackIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.trackIds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TracksBulkDeletePostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TracksBulkDeletePostRequestBuilder();
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

