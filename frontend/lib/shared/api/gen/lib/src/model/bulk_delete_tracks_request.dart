//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bulk_delete_tracks_request.g.dart';

/// BulkDeleteTracksRequest
///
/// Properties:
/// * [trackIds] 
@BuiltValue()
abstract class BulkDeleteTracksRequest implements Built<BulkDeleteTracksRequest, BulkDeleteTracksRequestBuilder> {
  @BuiltValueField(wireName: r'trackIds')
  BuiltList<String>? get trackIds;

  BulkDeleteTracksRequest._();

  factory BulkDeleteTracksRequest([void updates(BulkDeleteTracksRequestBuilder b)]) = _$BulkDeleteTracksRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BulkDeleteTracksRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BulkDeleteTracksRequest> get serializer => _$BulkDeleteTracksRequestSerializer();
}

class _$BulkDeleteTracksRequestSerializer implements PrimitiveSerializer<BulkDeleteTracksRequest> {
  @override
  final Iterable<Type> types = const [BulkDeleteTracksRequest, _$BulkDeleteTracksRequest];

  @override
  final String wireName = r'BulkDeleteTracksRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BulkDeleteTracksRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.trackIds != null) {
      yield r'trackIds';
      yield serializers.serialize(
        object.trackIds,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BulkDeleteTracksRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BulkDeleteTracksRequestBuilder result,
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
  BulkDeleteTracksRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BulkDeleteTracksRequestBuilder();
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

