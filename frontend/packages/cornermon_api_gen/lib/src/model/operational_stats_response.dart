//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/announcement_read_stat_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/track_message_count_response.dart';
import 'package:cornermon_api_gen/src/model/admin_operation_count_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'operational_stats_response.g.dart';

/// OperationalStatsResponse
///
/// Properties:
/// * [adminOperationCounts] 
/// * [announcementReadStats] 
/// * [deviceApprovedCount] 
/// * [deviceRejectedCount] 
/// * [deviceRequestCount] 
/// * [deviceRevokedCount] 
/// * [pinLoginFailureCount] 
/// * [pinLoginSuccessCount] 
/// * [trackDirectMessageCounts] 
@BuiltValue()
abstract class OperationalStatsResponse implements Built<OperationalStatsResponse, OperationalStatsResponseBuilder> {
  @BuiltValueField(wireName: r'adminOperationCounts')
  BuiltList<AdminOperationCountResponse>? get adminOperationCounts;

  @BuiltValueField(wireName: r'announcementReadStats')
  BuiltList<AnnouncementReadStatResponse>? get announcementReadStats;

  @BuiltValueField(wireName: r'deviceApprovedCount')
  int? get deviceApprovedCount;

  @BuiltValueField(wireName: r'deviceRejectedCount')
  int? get deviceRejectedCount;

  @BuiltValueField(wireName: r'deviceRequestCount')
  int? get deviceRequestCount;

  @BuiltValueField(wireName: r'deviceRevokedCount')
  int? get deviceRevokedCount;

  @BuiltValueField(wireName: r'pinLoginFailureCount')
  int? get pinLoginFailureCount;

  @BuiltValueField(wireName: r'pinLoginSuccessCount')
  int? get pinLoginSuccessCount;

  @BuiltValueField(wireName: r'trackDirectMessageCounts')
  BuiltList<TrackMessageCountResponse>? get trackDirectMessageCounts;

  OperationalStatsResponse._();

  factory OperationalStatsResponse([void updates(OperationalStatsResponseBuilder b)]) = _$OperationalStatsResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OperationalStatsResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OperationalStatsResponse> get serializer => _$OperationalStatsResponseSerializer();
}

class _$OperationalStatsResponseSerializer implements PrimitiveSerializer<OperationalStatsResponse> {
  @override
  final Iterable<Type> types = const [OperationalStatsResponse, _$OperationalStatsResponse];

  @override
  final String wireName = r'OperationalStatsResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OperationalStatsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.adminOperationCounts != null) {
      yield r'adminOperationCounts';
      yield serializers.serialize(
        object.adminOperationCounts,
        specifiedType: const FullType(BuiltList, [FullType(AdminOperationCountResponse)]),
      );
    }
    if (object.announcementReadStats != null) {
      yield r'announcementReadStats';
      yield serializers.serialize(
        object.announcementReadStats,
        specifiedType: const FullType(BuiltList, [FullType(AnnouncementReadStatResponse)]),
      );
    }
    if (object.deviceApprovedCount != null) {
      yield r'deviceApprovedCount';
      yield serializers.serialize(
        object.deviceApprovedCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.deviceRejectedCount != null) {
      yield r'deviceRejectedCount';
      yield serializers.serialize(
        object.deviceRejectedCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.deviceRequestCount != null) {
      yield r'deviceRequestCount';
      yield serializers.serialize(
        object.deviceRequestCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.deviceRevokedCount != null) {
      yield r'deviceRevokedCount';
      yield serializers.serialize(
        object.deviceRevokedCount,
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
    if (object.pinLoginSuccessCount != null) {
      yield r'pinLoginSuccessCount';
      yield serializers.serialize(
        object.pinLoginSuccessCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.trackDirectMessageCounts != null) {
      yield r'trackDirectMessageCounts';
      yield serializers.serialize(
        object.trackDirectMessageCounts,
        specifiedType: const FullType(BuiltList, [FullType(TrackMessageCountResponse)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OperationalStatsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OperationalStatsResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'adminOperationCounts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminOperationCountResponse)]),
          ) as BuiltList<AdminOperationCountResponse>;
          result.adminOperationCounts.replace(valueDes);
          break;
        case r'announcementReadStats':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AnnouncementReadStatResponse)]),
          ) as BuiltList<AnnouncementReadStatResponse>;
          result.announcementReadStats.replace(valueDes);
          break;
        case r'deviceApprovedCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.deviceApprovedCount = valueDes;
          break;
        case r'deviceRejectedCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.deviceRejectedCount = valueDes;
          break;
        case r'deviceRequestCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.deviceRequestCount = valueDes;
          break;
        case r'deviceRevokedCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.deviceRevokedCount = valueDes;
          break;
        case r'pinLoginFailureCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pinLoginFailureCount = valueDes;
          break;
        case r'pinLoginSuccessCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pinLoginSuccessCount = valueDes;
          break;
        case r'trackDirectMessageCounts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TrackMessageCountResponse)]),
          ) as BuiltList<TrackMessageCountResponse>;
          result.trackDirectMessageCounts.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OperationalStatsResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OperationalStatsResponseBuilder();
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

