//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'corners_id_patch_request.g.dart';

/// CornersIdPatchRequest
///
/// Properties:
/// * [name] 
/// * [targetMinutes] 
@BuiltValue()
abstract class CornersIdPatchRequest implements Built<CornersIdPatchRequest, CornersIdPatchRequestBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'targetMinutes')
  int? get targetMinutes;

  CornersIdPatchRequest._();

  factory CornersIdPatchRequest([void updates(CornersIdPatchRequestBuilder b)]) = _$CornersIdPatchRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CornersIdPatchRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CornersIdPatchRequest> get serializer => _$CornersIdPatchRequestSerializer();
}

class _$CornersIdPatchRequestSerializer implements PrimitiveSerializer<CornersIdPatchRequest> {
  @override
  final Iterable<Type> types = const [CornersIdPatchRequest, _$CornersIdPatchRequest];

  @override
  final String wireName = r'CornersIdPatchRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CornersIdPatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.targetMinutes != null) {
      yield r'targetMinutes';
      yield serializers.serialize(
        object.targetMinutes,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CornersIdPatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CornersIdPatchRequestBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CornersIdPatchRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CornersIdPatchRequestBuilder();
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

