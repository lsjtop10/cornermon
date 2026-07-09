//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/operational_stats_admin_action_counts_inner.dart';
import 'package:cornermon_api_gen/src/model/operational_stats_direct_message_count_per_track_inner.dart';
import 'package:cornermon_api_gen/src/model/operational_stats_broadcast_read_rates_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'operational_stats.g.dart';

/// OperationalStats
///
/// Properties:
/// * [pinLoginSuccessCount] 
/// * [pinLoginFailureCount] 
/// * [pinLoginFailureRate] 
/// * [deviceRegistrationCount] 
/// * [deviceApprovalCount] 
/// * [deviceRejectionCount] 
/// * [deviceRevocationCount] 
/// * [adminActionCounts] 
/// * [directMessageCountPerTrack] 
/// * [broadcastReadRates] 
@BuiltValue()
abstract class OperationalStats implements Built<OperationalStats, OperationalStatsBuilder> {
  @BuiltValueField(wireName: r'pinLoginSuccessCount')
  int? get pinLoginSuccessCount;

  @BuiltValueField(wireName: r'pinLoginFailureCount')
  int? get pinLoginFailureCount;

  @BuiltValueField(wireName: r'pinLoginFailureRate')
  double? get pinLoginFailureRate;

  @BuiltValueField(wireName: r'deviceRegistrationCount')
  int? get deviceRegistrationCount;

  @BuiltValueField(wireName: r'deviceApprovalCount')
  int? get deviceApprovalCount;

  @BuiltValueField(wireName: r'deviceRejectionCount')
  int? get deviceRejectionCount;

  @BuiltValueField(wireName: r'deviceRevocationCount')
  int? get deviceRevocationCount;

  @BuiltValueField(wireName: r'adminActionCounts')
  BuiltList<OperationalStatsAdminActionCountsInner>? get adminActionCounts;

  @BuiltValueField(wireName: r'directMessageCountPerTrack')
  BuiltList<OperationalStatsDirectMessageCountPerTrackInner>? get directMessageCountPerTrack;

  @BuiltValueField(wireName: r'broadcastReadRates')
  BuiltList<OperationalStatsBroadcastReadRatesInner>? get broadcastReadRates;

  OperationalStats._();

  factory OperationalStats([void updates(OperationalStatsBuilder b)]) = _$OperationalStats;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OperationalStatsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OperationalStats> get serializer => _$OperationalStatsSerializer();
}

class _$OperationalStatsSerializer implements PrimitiveSerializer<OperationalStats> {
  @override
  final Iterable<Type> types = const [OperationalStats, _$OperationalStats];

  @override
  final String wireName = r'OperationalStats';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OperationalStats object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.pinLoginSuccessCount != null) {
      yield r'pinLoginSuccessCount';
      yield serializers.serialize(
        object.pinLoginSuccessCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.pinLoginFailureCount != null) {
      yield r'pinLoginFailureCount';
      yield serializers.serialize(
        object.pinLoginFailureCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.pinLoginFailureRate != null) {
      yield r'pinLoginFailureRate';
      yield serializers.serialize(
        object.pinLoginFailureRate,
        specifiedType: const FullType(double),
      );
    }
    if (object.deviceRegistrationCount != null) {
      yield r'deviceRegistrationCount';
      yield serializers.serialize(
        object.deviceRegistrationCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.deviceApprovalCount != null) {
      yield r'deviceApprovalCount';
      yield serializers.serialize(
        object.deviceApprovalCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.deviceRejectionCount != null) {
      yield r'deviceRejectionCount';
      yield serializers.serialize(
        object.deviceRejectionCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.deviceRevocationCount != null) {
      yield r'deviceRevocationCount';
      yield serializers.serialize(
        object.deviceRevocationCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.adminActionCounts != null) {
      yield r'adminActionCounts';
      yield serializers.serialize(
        object.adminActionCounts,
        specifiedType: const FullType(BuiltList, [FullType(OperationalStatsAdminActionCountsInner)]),
      );
    }
    if (object.directMessageCountPerTrack != null) {
      yield r'directMessageCountPerTrack';
      yield serializers.serialize(
        object.directMessageCountPerTrack,
        specifiedType: const FullType(BuiltList, [FullType(OperationalStatsDirectMessageCountPerTrackInner)]),
      );
    }
    if (object.broadcastReadRates != null) {
      yield r'broadcastReadRates';
      yield serializers.serialize(
        object.broadcastReadRates,
        specifiedType: const FullType(BuiltList, [FullType(OperationalStatsBroadcastReadRatesInner)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OperationalStats object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OperationalStatsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'pinLoginSuccessCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pinLoginSuccessCount = valueDes;
          break;
        case r'pinLoginFailureCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pinLoginFailureCount = valueDes;
          break;
        case r'pinLoginFailureRate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.pinLoginFailureRate = valueDes;
          break;
        case r'deviceRegistrationCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.deviceRegistrationCount = valueDes;
          break;
        case r'deviceApprovalCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.deviceApprovalCount = valueDes;
          break;
        case r'deviceRejectionCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.deviceRejectionCount = valueDes;
          break;
        case r'deviceRevocationCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.deviceRevocationCount = valueDes;
          break;
        case r'adminActionCounts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OperationalStatsAdminActionCountsInner)]),
          ) as BuiltList<OperationalStatsAdminActionCountsInner>;
          result.adminActionCounts.replace(valueDes);
          break;
        case r'directMessageCountPerTrack':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OperationalStatsDirectMessageCountPerTrackInner)]),
          ) as BuiltList<OperationalStatsDirectMessageCountPerTrackInner>;
          result.directMessageCountPerTrack.replace(valueDes);
          break;
        case r'broadcastReadRates':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OperationalStatsBroadcastReadRatesInner)]),
          ) as BuiltList<OperationalStatsBroadcastReadRatesInner>;
          result.broadcastReadRates.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OperationalStats deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OperationalStatsBuilder();
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

