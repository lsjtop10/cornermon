//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracks_track_id_visits_start_post_request_one_of1.g.dart';

/// TracksTrackIdVisitsStartPostRequestOneOf1
///
/// Properties:
/// * [groupId] 
/// * [method] 
@BuiltValue()
abstract class TracksTrackIdVisitsStartPostRequestOneOf1 implements Built<TracksTrackIdVisitsStartPostRequestOneOf1, TracksTrackIdVisitsStartPostRequestOneOf1Builder> {
  @BuiltValueField(wireName: r'groupId')
  String get groupId;

  @BuiltValueField(wireName: r'method')
  TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum get method;
  // enum methodEnum {  MANUAL,  };

  TracksTrackIdVisitsStartPostRequestOneOf1._();

  factory TracksTrackIdVisitsStartPostRequestOneOf1([void updates(TracksTrackIdVisitsStartPostRequestOneOf1Builder b)]) = _$TracksTrackIdVisitsStartPostRequestOneOf1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TracksTrackIdVisitsStartPostRequestOneOf1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TracksTrackIdVisitsStartPostRequestOneOf1> get serializer => _$TracksTrackIdVisitsStartPostRequestOneOf1Serializer();
}

class _$TracksTrackIdVisitsStartPostRequestOneOf1Serializer implements PrimitiveSerializer<TracksTrackIdVisitsStartPostRequestOneOf1> {
  @override
  final Iterable<Type> types = const [TracksTrackIdVisitsStartPostRequestOneOf1, _$TracksTrackIdVisitsStartPostRequestOneOf1];

  @override
  final String wireName = r'TracksTrackIdVisitsStartPostRequestOneOf1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TracksTrackIdVisitsStartPostRequestOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'groupId';
    yield serializers.serialize(
      object.groupId,
      specifiedType: const FullType(String),
    );
    yield r'method';
    yield serializers.serialize(
      object.method,
      specifiedType: const FullType(TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TracksTrackIdVisitsStartPostRequestOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TracksTrackIdVisitsStartPostRequestOneOf1Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'groupId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.groupId = valueDes;
          break;
        case r'method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum),
          ) as TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum;
          result.method = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TracksTrackIdVisitsStartPostRequestOneOf1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TracksTrackIdVisitsStartPostRequestOneOf1Builder();
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

class TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'MANUAL')
  static const TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum MANUAL = _$tracksTrackIdVisitsStartPostRequestOneOf1MethodEnum_MANUAL;

  static Serializer<TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum> get serializer => _$tracksTrackIdVisitsStartPostRequestOneOf1MethodEnumSerializer;

  const TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum._(String name): super(name);

  static BuiltSet<TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum> get values => _$tracksTrackIdVisitsStartPostRequestOneOf1MethodEnumValues;
  static TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum valueOf(String name) => _$tracksTrackIdVisitsStartPostRequestOneOf1MethodEnumValueOf(name);
}

