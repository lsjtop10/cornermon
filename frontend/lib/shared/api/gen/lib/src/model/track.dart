//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/track_status.dart';
import 'package:cornermon_api_gen/src/model/track_operational_status.dart';
import 'package:cornermon_api_gen/src/model/visit_summary.dart';
import 'package:cornermon_api_gen/src/model/track_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'track.g.dart';

/// Track
///
/// Properties:
/// * [id] 
/// * [cornerId] 
/// * [trackNo] - 코너 내 트랙 번호 (자동 부여)
/// * [status] 
/// * [operationalStatus] 
/// * [pin] - 6자리 숫자 PIN (관리자 전용 응답에만 포함)
/// * [currentVisit] 
@BuiltValue()
abstract class Track implements TrackSummary, Built<Track, TrackBuilder> {
  /// 6자리 숫자 PIN (관리자 전용 응답에만 포함)
  @BuiltValueField(wireName: r'pin')
  String? get pin;

  @BuiltValueField(wireName: r'currentVisit')
  VisitSummary? get currentVisit;

  Track._();

  factory Track([void updates(TrackBuilder b)]) = _$Track;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Track> get serializer => _$TrackSerializer();
}

class _$TrackSerializer implements PrimitiveSerializer<Track> {
  @override
  final Iterable<Type> types = const [Track, _$Track];

  @override
  final String wireName = r'Track';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Track object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.operationalStatus != null) {
      yield r'operationalStatus';
      yield serializers.serialize(
        object.operationalStatus,
        specifiedType: const FullType(TrackOperationalStatus),
      );
    }
    if (object.pin != null) {
      yield r'pin';
      yield serializers.serialize(
        object.pin,
        specifiedType: const FullType(String),
      );
    }
    if (object.currentVisit != null) {
      yield r'currentVisit';
      yield serializers.serialize(
        object.currentVisit,
        specifiedType: const FullType(VisitSummary),
      );
    }
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'trackNo';
    yield serializers.serialize(
      object.trackNo,
      specifiedType: const FullType(int),
    );
    yield r'cornerId';
    yield serializers.serialize(
      object.cornerId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(TrackStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Track object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'operationalStatus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TrackOperationalStatus),
          ) as TrackOperationalStatus;
          result.operationalStatus = valueDes;
          break;
        case r'pin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pin = valueDes;
          break;
        case r'currentVisit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(VisitSummary),
          ) as VisitSummary;
          result.currentVisit.replace(valueDes);
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'trackNo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.trackNo = valueDes;
          break;
        case r'cornerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cornerId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TrackStatus),
          ) as TrackStatus;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Track deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackBuilder();
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

