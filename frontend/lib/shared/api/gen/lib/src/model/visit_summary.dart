//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/visit_status.dart';
import 'package:cornermon_api_gen/src/model/visit_input_method.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'visit_summary.g.dart';

/// VisitSummary
///
/// Properties:
/// * [id] 
/// * [groupId] 
/// * [cornerId] 
/// * [trackId] 
/// * [status] 
/// * [inputMethod] 
/// * [startedAt] 
/// * [endedAt] 
/// * [durationSeconds] - 실제 소요 시간 (초)
/// * [deviationSeconds] - 목표시간 편차 = 실제소요시간 - 목표시간 (초)
@BuiltValue()
abstract class VisitSummary implements Built<VisitSummary, VisitSummaryBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'groupId')
  String get groupId;

  @BuiltValueField(wireName: r'cornerId')
  String get cornerId;

  @BuiltValueField(wireName: r'trackId')
  String get trackId;

  @BuiltValueField(wireName: r'status')
  VisitStatus get status;
  // enum statusEnum {  IN_PROGRESS,  COMPLETED,  };

  @BuiltValueField(wireName: r'inputMethod')
  VisitInputMethod? get inputMethod;
  // enum inputMethodEnum {  QR_SCAN,  MANUAL,  };

  @BuiltValueField(wireName: r'startedAt')
  DateTime get startedAt;

  @BuiltValueField(wireName: r'endedAt')
  DateTime? get endedAt;

  /// 실제 소요 시간 (초)
  @BuiltValueField(wireName: r'durationSeconds')
  int? get durationSeconds;

  /// 목표시간 편차 = 실제소요시간 - 목표시간 (초)
  @BuiltValueField(wireName: r'deviationSeconds')
  int? get deviationSeconds;

  VisitSummary._();

  factory VisitSummary([void updates(VisitSummaryBuilder b)]) = _$VisitSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VisitSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VisitSummary> get serializer => _$VisitSummarySerializer();
}

class _$VisitSummarySerializer implements PrimitiveSerializer<VisitSummary> {
  @override
  final Iterable<Type> types = const [VisitSummary, _$VisitSummary];

  @override
  final String wireName = r'VisitSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VisitSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'groupId';
    yield serializers.serialize(
      object.groupId,
      specifiedType: const FullType(String),
    );
    yield r'cornerId';
    yield serializers.serialize(
      object.cornerId,
      specifiedType: const FullType(String),
    );
    yield r'trackId';
    yield serializers.serialize(
      object.trackId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(VisitStatus),
    );
    if (object.inputMethod != null) {
      yield r'inputMethod';
      yield serializers.serialize(
        object.inputMethod,
        specifiedType: const FullType(VisitInputMethod),
      );
    }
    yield r'startedAt';
    yield serializers.serialize(
      object.startedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.endedAt != null) {
      yield r'endedAt';
      yield serializers.serialize(
        object.endedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.durationSeconds != null) {
      yield r'durationSeconds';
      yield serializers.serialize(
        object.durationSeconds,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.deviationSeconds != null) {
      yield r'deviationSeconds';
      yield serializers.serialize(
        object.deviationSeconds,
        specifiedType: const FullType.nullable(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    VisitSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required VisitSummaryBuilder result,
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
        case r'groupId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.groupId = valueDes;
          break;
        case r'cornerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cornerId = valueDes;
          break;
        case r'trackId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.trackId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(VisitStatus),
          ) as VisitStatus;
          result.status = valueDes;
          break;
        case r'inputMethod':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(VisitInputMethod),
          ) as VisitInputMethod;
          result.inputMethod = valueDes;
          break;
        case r'startedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startedAt = valueDes;
          break;
        case r'endedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endedAt = valueDes;
          break;
        case r'durationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.durationSeconds = valueDes;
          break;
        case r'deviationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.deviationSeconds = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VisitSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VisitSummaryBuilder();
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

