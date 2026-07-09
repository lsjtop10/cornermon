//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/corner_operational_status.dart';
import 'package:cornermon_api_gen/src/model/track_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'corner.g.dart';

/// Corner
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [targetMinutes] - 목표 소요 시간 (분)
/// * [status] 
/// * [isBottleneck] - 병목 판정 여부 (실시간 집계 기반)
/// * [activeTracks] 
@BuiltValue()
abstract class Corner implements Built<Corner, CornerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  /// 목표 소요 시간 (분)
  @BuiltValueField(wireName: r'targetMinutes')
  int get targetMinutes;

  @BuiltValueField(wireName: r'status')
  CornerOperationalStatus get status;
  // enum statusEnum {  INACTIVE,  IDLE,  BUSY,  };

  /// 병목 판정 여부 (실시간 집계 기반)
  @BuiltValueField(wireName: r'isBottleneck')
  bool? get isBottleneck;

  @BuiltValueField(wireName: r'activeTracks')
  BuiltList<TrackSummary>? get activeTracks;

  Corner._();

  factory Corner([void updates(CornerBuilder b)]) = _$Corner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CornerBuilder b) => b
      ..targetMinutes = 10;

  @BuiltValueSerializer(custom: true)
  static Serializer<Corner> get serializer => _$CornerSerializer();
}

class _$CornerSerializer implements PrimitiveSerializer<Corner> {
  @override
  final Iterable<Type> types = const [Corner, _$Corner];

  @override
  final String wireName = r'Corner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Corner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'targetMinutes';
    yield serializers.serialize(
      object.targetMinutes,
      specifiedType: const FullType(int),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(CornerOperationalStatus),
    );
    if (object.isBottleneck != null) {
      yield r'isBottleneck';
      yield serializers.serialize(
        object.isBottleneck,
        specifiedType: const FullType(bool),
      );
    }
    if (object.activeTracks != null) {
      yield r'activeTracks';
      yield serializers.serialize(
        object.activeTracks,
        specifiedType: const FullType(BuiltList, [FullType(TrackSummary)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Corner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CornerBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CornerOperationalStatus),
          ) as CornerOperationalStatus;
          result.status = valueDes;
          break;
        case r'isBottleneck':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isBottleneck = valueDes;
          break;
        case r'activeTracks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TrackSummary)]),
          ) as BuiltList<TrackSummary>;
          result.activeTracks.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Corner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CornerBuilder();
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

