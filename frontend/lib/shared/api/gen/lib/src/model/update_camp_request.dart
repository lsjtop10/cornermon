// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_camp_request.g.dart';

/// UpdateCampRequest
///
/// Properties:
/// * [bottleneckMinSamples] 
/// * [bottleneckRatioPct] 
/// * [endAt] 
/// * [name] 
/// * [startAt] 
@BuiltValue()
abstract class UpdateCampRequest implements Built<UpdateCampRequest, UpdateCampRequestBuilder> {
  @BuiltValueField(wireName: r'bottleneckMinSamples')
  int? get bottleneckMinSamples;

  @BuiltValueField(wireName: r'bottleneckRatioPct')
  int? get bottleneckRatioPct;

  @BuiltValueField(wireName: r'endAt')
  DateTime? get endAt;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'startAt')
  DateTime? get startAt;

  UpdateCampRequest._();

  factory UpdateCampRequest([void updates(UpdateCampRequestBuilder b)]) = _$UpdateCampRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateCampRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateCampRequest> get serializer => _$UpdateCampRequestSerializer();
}

class _$UpdateCampRequestSerializer implements PrimitiveSerializer<UpdateCampRequest> {
  @override
  final Iterable<Type> types = const [UpdateCampRequest, _$UpdateCampRequest];

  @override
  final String wireName = r'UpdateCampRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateCampRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.bottleneckMinSamples != null) {
      yield r'bottleneckMinSamples';
      yield serializers.serialize(
        object.bottleneckMinSamples,
        specifiedType: const FullType(int),
      );
    }
    if (object.bottleneckRatioPct != null) {
      yield r'bottleneckRatioPct';
      yield serializers.serialize(
        object.bottleneckRatioPct,
        specifiedType: const FullType(int),
      );
    }
    if (object.endAt != null) {
      yield r'endAt';
      yield serializers.serialize(
        object.endAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.startAt != null) {
      yield r'startAt';
      yield serializers.serialize(
        object.startAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateCampRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateCampRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'bottleneckMinSamples':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.bottleneckMinSamples = valueDes;
          break;
        case r'bottleneckRatioPct':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.bottleneckRatioPct = valueDes;
          break;
        case r'endAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.endAt = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'startAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateCampRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateCampRequestBuilder();
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

