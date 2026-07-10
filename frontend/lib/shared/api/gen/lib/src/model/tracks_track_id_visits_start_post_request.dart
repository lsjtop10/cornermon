//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/tracks_track_id_visits_start_post_request_one_of.dart';
import 'package:cornermon_api_gen/src/model/tracks_track_id_visits_start_post_request_one_of1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'tracks_track_id_visits_start_post_request.g.dart';

/// TracksTrackIdVisitsStartPostRequest
///
/// Properties:
/// * [qrToken] - QR 배지에서 스캔한 페이로드
/// * [groupId] 
/// * [method] 
@BuiltValue()
abstract class TracksTrackIdVisitsStartPostRequest implements Built<TracksTrackIdVisitsStartPostRequest, TracksTrackIdVisitsStartPostRequestBuilder> {
  /// One Of [TracksTrackIdVisitsStartPostRequestOneOf], [TracksTrackIdVisitsStartPostRequestOneOf1]
  OneOf get oneOf;

  TracksTrackIdVisitsStartPostRequest._();

  factory TracksTrackIdVisitsStartPostRequest([void updates(TracksTrackIdVisitsStartPostRequestBuilder b)]) = _$TracksTrackIdVisitsStartPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TracksTrackIdVisitsStartPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TracksTrackIdVisitsStartPostRequest> get serializer => _$TracksTrackIdVisitsStartPostRequestSerializer();
}

class _$TracksTrackIdVisitsStartPostRequestSerializer implements PrimitiveSerializer<TracksTrackIdVisitsStartPostRequest> {
  @override
  final Iterable<Type> types = const [TracksTrackIdVisitsStartPostRequest, _$TracksTrackIdVisitsStartPostRequest];

  @override
  final String wireName = r'TracksTrackIdVisitsStartPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TracksTrackIdVisitsStartPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    TracksTrackIdVisitsStartPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  TracksTrackIdVisitsStartPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TracksTrackIdVisitsStartPostRequestBuilder();
    Object? oneOfDataSrc;
    final targetType = const FullType(OneOf, [FullType(TracksTrackIdVisitsStartPostRequestOneOf), FullType(TracksTrackIdVisitsStartPostRequestOneOf1), ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc, specifiedType: targetType) as OneOf;
    return result.build();
  }
}

class TracksTrackIdVisitsStartPostRequestMethodEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'MANUAL')
  static const TracksTrackIdVisitsStartPostRequestMethodEnum MANUAL = _$tracksTrackIdVisitsStartPostRequestMethodEnum_MANUAL;

  static Serializer<TracksTrackIdVisitsStartPostRequestMethodEnum> get serializer => _$tracksTrackIdVisitsStartPostRequestMethodEnumSerializer;

  const TracksTrackIdVisitsStartPostRequestMethodEnum._(String name): super(name);

  static BuiltSet<TracksTrackIdVisitsStartPostRequestMethodEnum> get values => _$tracksTrackIdVisitsStartPostRequestMethodEnumValues;
  static TracksTrackIdVisitsStartPostRequestMethodEnum valueOf(String name) => _$tracksTrackIdVisitsStartPostRequestMethodEnumValueOf(name);
}

