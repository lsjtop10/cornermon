//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'corners_post_request_corners_inner.g.dart';

/// CornersPostRequestCornersInner
///
/// Properties:
/// * [name] 
/// * [targetMinutes] 
/// * [initialTrackCount] 
@BuiltValue()
abstract class CornersPostRequestCornersInner implements Built<CornersPostRequestCornersInner, CornersPostRequestCornersInnerBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'targetMinutes')
  int? get targetMinutes;

  @BuiltValueField(wireName: r'initialTrackCount')
  int? get initialTrackCount;

  CornersPostRequestCornersInner._();

  factory CornersPostRequestCornersInner([void updates(CornersPostRequestCornersInnerBuilder b)]) = _$CornersPostRequestCornersInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CornersPostRequestCornersInnerBuilder b) => b
      ..targetMinutes = 10
      ..initialTrackCount = 1;

  @BuiltValueSerializer(custom: true)
  static Serializer<CornersPostRequestCornersInner> get serializer => _$CornersPostRequestCornersInnerSerializer();
}

class _$CornersPostRequestCornersInnerSerializer implements PrimitiveSerializer<CornersPostRequestCornersInner> {
  @override
  final Iterable<Type> types = const [CornersPostRequestCornersInner, _$CornersPostRequestCornersInner];

  @override
  final String wireName = r'CornersPostRequestCornersInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CornersPostRequestCornersInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.targetMinutes != null) {
      yield r'targetMinutes';
      yield serializers.serialize(
        object.targetMinutes,
        specifiedType: const FullType(int),
      );
    }
    if (object.initialTrackCount != null) {
      yield r'initialTrackCount';
      yield serializers.serialize(
        object.initialTrackCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CornersPostRequestCornersInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CornersPostRequestCornersInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'targetMinutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.targetMinutes = valueDes;
          break;
        case r'initialTrackCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.initialTrackCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CornersPostRequestCornersInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CornersPostRequestCornersInnerBuilder();
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

