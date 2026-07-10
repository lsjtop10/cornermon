//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'operational_stats_direct_message_count_per_track_inner.g.dart';

/// OperationalStatsDirectMessageCountPerTrackInner
///
/// Properties:
/// * [trackId] 
/// * [messageCount] 
@BuiltValue()
abstract class OperationalStatsDirectMessageCountPerTrackInner implements Built<OperationalStatsDirectMessageCountPerTrackInner, OperationalStatsDirectMessageCountPerTrackInnerBuilder> {
  @BuiltValueField(wireName: r'trackId')
  String? get trackId;

  @BuiltValueField(wireName: r'messageCount')
  int? get messageCount;

  OperationalStatsDirectMessageCountPerTrackInner._();

  factory OperationalStatsDirectMessageCountPerTrackInner([void updates(OperationalStatsDirectMessageCountPerTrackInnerBuilder b)]) = _$OperationalStatsDirectMessageCountPerTrackInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OperationalStatsDirectMessageCountPerTrackInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OperationalStatsDirectMessageCountPerTrackInner> get serializer => _$OperationalStatsDirectMessageCountPerTrackInnerSerializer();
}

class _$OperationalStatsDirectMessageCountPerTrackInnerSerializer implements PrimitiveSerializer<OperationalStatsDirectMessageCountPerTrackInner> {
  @override
  final Iterable<Type> types = const [OperationalStatsDirectMessageCountPerTrackInner, _$OperationalStatsDirectMessageCountPerTrackInner];

  @override
  final String wireName = r'OperationalStatsDirectMessageCountPerTrackInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OperationalStatsDirectMessageCountPerTrackInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.trackId != null) {
      yield r'trackId';
      yield serializers.serialize(
        object.trackId,
        specifiedType: const FullType(String),
      );
    }
    if (object.messageCount != null) {
      yield r'messageCount';
      yield serializers.serialize(
        object.messageCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OperationalStatsDirectMessageCountPerTrackInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OperationalStatsDirectMessageCountPerTrackInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'trackId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.trackId = valueDes;
          break;
        case r'messageCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.messageCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OperationalStatsDirectMessageCountPerTrackInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OperationalStatsDirectMessageCountPerTrackInnerBuilder();
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

