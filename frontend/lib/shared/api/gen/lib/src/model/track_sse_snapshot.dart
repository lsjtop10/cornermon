//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/visit_summary.dart';
import 'package:cornermon_api_gen/src/model/corner.dart';
import 'package:cornermon_api_gen/src/model/track.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'track_sse_snapshot.g.dart';

/// 진행자 SSE 최초/재연결 시 전송되는 트랙 스냅샷
///
/// Properties:
/// * [track] 
/// * [corner] 
/// * [currentVisit] 
/// * [unreadBroadcastCount] 
@BuiltValue()
abstract class TrackSseSnapshot implements Built<TrackSseSnapshot, TrackSseSnapshotBuilder> {
  @BuiltValueField(wireName: r'track')
  Track? get track;

  @BuiltValueField(wireName: r'corner')
  Corner? get corner;

  @BuiltValueField(wireName: r'currentVisit')
  VisitSummary? get currentVisit;

  @BuiltValueField(wireName: r'unreadBroadcastCount')
  int? get unreadBroadcastCount;

  TrackSseSnapshot._();

  factory TrackSseSnapshot([void updates(TrackSseSnapshotBuilder b)]) = _$TrackSseSnapshot;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackSseSnapshotBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackSseSnapshot> get serializer => _$TrackSseSnapshotSerializer();
}

class _$TrackSseSnapshotSerializer implements PrimitiveSerializer<TrackSseSnapshot> {
  @override
  final Iterable<Type> types = const [TrackSseSnapshot, _$TrackSseSnapshot];

  @override
  final String wireName = r'TrackSseSnapshot';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackSseSnapshot object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.track != null) {
      yield r'track';
      yield serializers.serialize(
        object.track,
        specifiedType: const FullType(Track),
      );
    }
    if (object.corner != null) {
      yield r'corner';
      yield serializers.serialize(
        object.corner,
        specifiedType: const FullType(Corner),
      );
    }
    if (object.currentVisit != null) {
      yield r'currentVisit';
      yield serializers.serialize(
        object.currentVisit,
        specifiedType: const FullType(VisitSummary),
      );
    }
    if (object.unreadBroadcastCount != null) {
      yield r'unreadBroadcastCount';
      yield serializers.serialize(
        object.unreadBroadcastCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackSseSnapshot object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackSseSnapshotBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'track':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Track),
          ) as Track;
          result.track.replace(valueDes);
          break;
        case r'corner':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Corner),
          ) as Corner;
          result.corner.replace(valueDes);
          break;
        case r'currentVisit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(VisitSummary),
          ) as VisitSummary;
          result.currentVisit.replace(valueDes);
          break;
        case r'unreadBroadcastCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.unreadBroadcastCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackSseSnapshot deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackSseSnapshotBuilder();
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

