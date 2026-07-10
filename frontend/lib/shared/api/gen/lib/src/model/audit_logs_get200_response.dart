//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/audit_log.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'audit_logs_get200_response.g.dart';

/// AuditLogsGet200Response
///
/// Properties:
/// * [logs] 
/// * [hasMore] 
@BuiltValue()
abstract class AuditLogsGet200Response implements Built<AuditLogsGet200Response, AuditLogsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'logs')
  BuiltList<AuditLog>? get logs;

  @BuiltValueField(wireName: r'hasMore')
  bool? get hasMore;

  AuditLogsGet200Response._();

  factory AuditLogsGet200Response([void updates(AuditLogsGet200ResponseBuilder b)]) = _$AuditLogsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuditLogsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuditLogsGet200Response> get serializer => _$AuditLogsGet200ResponseSerializer();
}

class _$AuditLogsGet200ResponseSerializer implements PrimitiveSerializer<AuditLogsGet200Response> {
  @override
  final Iterable<Type> types = const [AuditLogsGet200Response, _$AuditLogsGet200Response];

  @override
  final String wireName = r'AuditLogsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuditLogsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.logs != null) {
      yield r'logs';
      yield serializers.serialize(
        object.logs,
        specifiedType: const FullType(BuiltList, [FullType(AuditLog)]),
      );
    }
    if (object.hasMore != null) {
      yield r'hasMore';
      yield serializers.serialize(
        object.hasMore,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuditLogsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuditLogsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'logs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AuditLog)]),
          ) as BuiltList<AuditLog>;
          result.logs.replace(valueDes);
          break;
        case r'hasMore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasMore = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuditLogsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuditLogsGet200ResponseBuilder();
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

