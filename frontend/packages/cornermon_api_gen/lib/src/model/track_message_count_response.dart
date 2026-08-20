//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'track_message_count_response.g.dart';

/// TrackMessageCountResponse
///
/// Properties:
/// * [count] 
/// * [trackId] 
/// * [trackLabel] 
@BuiltValue()
abstract class TrackMessageCountResponse implements Built<TrackMessageCountResponse, TrackMessageCountResponseBuilder> {
  @BuiltValueField(wireName: r'count')
  int? get count;

  @BuiltValueField(wireName: r'trackId')
  String? get trackId;

  @BuiltValueField(wireName: r'trackLabel')
  String? get trackLabel;

  TrackMessageCountResponse._();

  factory TrackMessageCountResponse([void updates(TrackMessageCountResponseBuilder b)]) = _$TrackMessageCountResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackMessageCountResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackMessageCountResponse> get serializer => _$TrackMessageCountResponseSerializer();
}

class _$TrackMessageCountResponseSerializer implements PrimitiveSerializer<TrackMessageCountResponse> {
  @override
  final Iterable<Type> types = const [TrackMessageCountResponse, _$TrackMessageCountResponse];

  @override
  final String wireName = r'TrackMessageCountResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackMessageCountResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.count != null) {
      yield r'count';
      yield serializers.serialize(
        object.count,
        specifiedType: const FullType(int),
      );
    }
    if (object.trackId != null) {
      yield r'trackId';
      yield serializers.serialize(
        object.trackId,
        specifiedType: const FullType(String),
      );
    }
    if (object.trackLabel != null) {
      yield r'trackLabel';
      yield serializers.serialize(
        object.trackLabel,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackMessageCountResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackMessageCountResponseBuilder result,
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
        case r'trackId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.trackId = valueDes;
          break;
        case r'trackLabel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.trackLabel = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackMessageCountResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackMessageCountResponseBuilder();
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

