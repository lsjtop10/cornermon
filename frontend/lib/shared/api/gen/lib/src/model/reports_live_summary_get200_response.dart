//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/reports_live_summary_get200_response_corners_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reports_live_summary_get200_response.g.dart';

/// ReportsLiveSummaryGet200Response
///
/// Properties:
/// * [totalGroups] 
/// * [finishedGroups] 
/// * [corners] 
@BuiltValue()
abstract class ReportsLiveSummaryGet200Response implements Built<ReportsLiveSummaryGet200Response, ReportsLiveSummaryGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'totalGroups')
  int? get totalGroups;

  @BuiltValueField(wireName: r'finishedGroups')
  int? get finishedGroups;

  @BuiltValueField(wireName: r'corners')
  BuiltList<ReportsLiveSummaryGet200ResponseCornersInner>? get corners;

  ReportsLiveSummaryGet200Response._();

  factory ReportsLiveSummaryGet200Response([void updates(ReportsLiveSummaryGet200ResponseBuilder b)]) = _$ReportsLiveSummaryGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReportsLiveSummaryGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReportsLiveSummaryGet200Response> get serializer => _$ReportsLiveSummaryGet200ResponseSerializer();
}

class _$ReportsLiveSummaryGet200ResponseSerializer implements PrimitiveSerializer<ReportsLiveSummaryGet200Response> {
  @override
  final Iterable<Type> types = const [ReportsLiveSummaryGet200Response, _$ReportsLiveSummaryGet200Response];

  @override
  final String wireName = r'ReportsLiveSummaryGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReportsLiveSummaryGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.totalGroups != null) {
      yield r'totalGroups';
      yield serializers.serialize(
        object.totalGroups,
        specifiedType: const FullType(int),
      );
    }
    if (object.finishedGroups != null) {
      yield r'finishedGroups';
      yield serializers.serialize(
        object.finishedGroups,
        specifiedType: const FullType(int),
      );
    }
    if (object.corners != null) {
      yield r'corners';
      yield serializers.serialize(
        object.corners,
        specifiedType: const FullType(BuiltList, [FullType(ReportsLiveSummaryGet200ResponseCornersInner)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ReportsLiveSummaryGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReportsLiveSummaryGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'totalGroups':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalGroups = valueDes;
          break;
        case r'finishedGroups':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.finishedGroups = valueDes;
          break;
        case r'corners':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ReportsLiveSummaryGet200ResponseCornersInner)]),
          ) as BuiltList<ReportsLiveSummaryGet200ResponseCornersInner>;
          result.corners.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReportsLiveSummaryGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReportsLiveSummaryGet200ResponseBuilder();
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

