//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/track_status.dart';
import 'package:cornermon_api_gen/src/model/track_operational_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'track_summary.g.dart';

/// TrackSummary
///
/// Properties:
/// * [id] 
/// * [cornerId] 
/// * [trackNo] - 코너 내 트랙 번호 (자동 부여)
/// * [status] 
/// * [operationalStatus] 
@BuiltValue(instantiable: false)
abstract class TrackSummary  {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'cornerId')
  String get cornerId;

  /// 코너 내 트랙 번호 (자동 부여)
  @BuiltValueField(wireName: r'trackNo')
  int get trackNo;

  @BuiltValueField(wireName: r'status')
  TrackStatus get status;
  // enum statusEnum {  ACTIVE,  DELETED,  };

  @BuiltValueField(wireName: r'operationalStatus')
  TrackOperationalStatus? get operationalStatus;
  // enum operationalStatusEnum {  IDLE,  BUSY,  };

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackSummary> get serializer => _$TrackSummarySerializer();
}

class _$TrackSummarySerializer implements PrimitiveSerializer<TrackSummary> {
  @override
  final Iterable<Type> types = const [TrackSummary];

  @override
  final String wireName = r'TrackSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'cornerId';
    yield serializers.serialize(
      object.cornerId,
      specifiedType: const FullType(String),
    );
    yield r'trackNo';
    yield serializers.serialize(
      object.trackNo,
      specifiedType: const FullType(int),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(TrackStatus),
    );
    if (object.operationalStatus != null) {
      yield r'operationalStatus';
      yield serializers.serialize(
        object.operationalStatus,
        specifiedType: const FullType(TrackOperationalStatus),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  @override
  TrackSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized, specifiedType: FullType($TrackSummary)) as $TrackSummary;
  }
}

/// a concrete implementation of [TrackSummary], since [TrackSummary] is not instantiable
@BuiltValue(instantiable: true)
abstract class $TrackSummary implements TrackSummary, Built<$TrackSummary, $TrackSummaryBuilder> {
  $TrackSummary._();

  factory $TrackSummary([void Function($TrackSummaryBuilder)? updates]) = _$$TrackSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($TrackSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$TrackSummary> get serializer => _$$TrackSummarySerializer();
}

class _$$TrackSummarySerializer implements PrimitiveSerializer<$TrackSummary> {
  @override
  final Iterable<Type> types = const [$TrackSummary, _$$TrackSummary];

  @override
  final String wireName = r'$TrackSummary';

  @override
  Object serialize(
    Serializers serializers,
    $TrackSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object, specifiedType: FullType(TrackSummary))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'cornerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cornerId = valueDes;
          break;
        case r'trackNo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.trackNo = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TrackStatus),
          ) as TrackStatus;
          result.status = valueDes;
          break;
        case r'operationalStatus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TrackOperationalStatus),
          ) as TrackOperationalStatus;
          result.operationalStatus = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  $TrackSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $TrackSummaryBuilder();
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

