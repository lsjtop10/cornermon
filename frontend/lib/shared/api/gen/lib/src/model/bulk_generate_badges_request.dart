//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bulk_generate_badges_request.g.dart';

/// BulkGenerateBadgesRequest
///
/// Properties:
/// * [count] 
@BuiltValue()
abstract class BulkGenerateBadgesRequest implements Built<BulkGenerateBadgesRequest, BulkGenerateBadgesRequestBuilder> {
  @BuiltValueField(wireName: r'count')
  int? get count;

  BulkGenerateBadgesRequest._();

  factory BulkGenerateBadgesRequest([void updates(BulkGenerateBadgesRequestBuilder b)]) = _$BulkGenerateBadgesRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BulkGenerateBadgesRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BulkGenerateBadgesRequest> get serializer => _$BulkGenerateBadgesRequestSerializer();
}

class _$BulkGenerateBadgesRequestSerializer implements PrimitiveSerializer<BulkGenerateBadgesRequest> {
  @override
  final Iterable<Type> types = const [BulkGenerateBadgesRequest, _$BulkGenerateBadgesRequest];

  @override
  final String wireName = r'BulkGenerateBadgesRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BulkGenerateBadgesRequest object, {
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
    BulkGenerateBadgesRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BulkGenerateBadgesRequestBuilder result,
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
  BulkGenerateBadgesRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BulkGenerateBadgesRequestBuilder();
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

