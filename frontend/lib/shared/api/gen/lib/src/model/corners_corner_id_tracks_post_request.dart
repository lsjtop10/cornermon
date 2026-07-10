//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'corners_corner_id_tracks_post_request.g.dart';

/// CornersCornerIdTracksPostRequest
///
/// Properties:
/// * [count] - 생성할 트랙 수
@BuiltValue()
abstract class CornersCornerIdTracksPostRequest implements Built<CornersCornerIdTracksPostRequest, CornersCornerIdTracksPostRequestBuilder> {
  /// 생성할 트랙 수
  @BuiltValueField(wireName: r'count')
  int? get count;

  CornersCornerIdTracksPostRequest._();

  factory CornersCornerIdTracksPostRequest([void updates(CornersCornerIdTracksPostRequestBuilder b)]) = _$CornersCornerIdTracksPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CornersCornerIdTracksPostRequestBuilder b) => b
      ..count = 1;

  @BuiltValueSerializer(custom: true)
  static Serializer<CornersCornerIdTracksPostRequest> get serializer => _$CornersCornerIdTracksPostRequestSerializer();
}

class _$CornersCornerIdTracksPostRequestSerializer implements PrimitiveSerializer<CornersCornerIdTracksPostRequest> {
  @override
  final Iterable<Type> types = const [CornersCornerIdTracksPostRequest, _$CornersCornerIdTracksPostRequest];

  @override
  final String wireName = r'CornersCornerIdTracksPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CornersCornerIdTracksPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.count != null) {
      yield r'count';
      yield serializers.serialize(
        object.count,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CornersCornerIdTracksPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CornersCornerIdTracksPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.count = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CornersCornerIdTracksPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CornersCornerIdTracksPostRequestBuilder();
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

