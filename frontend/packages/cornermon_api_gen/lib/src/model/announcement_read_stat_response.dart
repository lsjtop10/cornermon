//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'announcement_read_stat_response.g.dart';

/// AnnouncementReadStatResponse
///
/// Properties:
/// * [announcementContent] 
/// * [announcementId] 
/// * [readCount] 
/// * [totalRecipients] 
@BuiltValue()
abstract class AnnouncementReadStatResponse implements Built<AnnouncementReadStatResponse, AnnouncementReadStatResponseBuilder> {
  @BuiltValueField(wireName: r'announcementContent')
  String? get announcementContent;

  @BuiltValueField(wireName: r'announcementId')
  String? get announcementId;

  @BuiltValueField(wireName: r'readCount')
  int? get readCount;

  @BuiltValueField(wireName: r'totalRecipients')
  int? get totalRecipients;

  AnnouncementReadStatResponse._();

  factory AnnouncementReadStatResponse([void updates(AnnouncementReadStatResponseBuilder b)]) = _$AnnouncementReadStatResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnnouncementReadStatResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnnouncementReadStatResponse> get serializer => _$AnnouncementReadStatResponseSerializer();
}

class _$AnnouncementReadStatResponseSerializer implements PrimitiveSerializer<AnnouncementReadStatResponse> {
  @override
  final Iterable<Type> types = const [AnnouncementReadStatResponse, _$AnnouncementReadStatResponse];

  @override
  final String wireName = r'AnnouncementReadStatResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnnouncementReadStatResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.announcementContent != null) {
      yield r'announcementContent';
      yield serializers.serialize(
        object.announcementContent,
        specifiedType: const FullType(String),
      );
    }
    if (object.announcementId != null) {
      yield r'announcementId';
      yield serializers.serialize(
        object.announcementId,
        specifiedType: const FullType(String),
      );
    }
    if (object.readCount != null) {
      yield r'readCount';
      yield serializers.serialize(
        object.readCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.totalRecipients != null) {
      yield r'totalRecipients';
      yield serializers.serialize(
        object.totalRecipients,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AnnouncementReadStatResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AnnouncementReadStatResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'announcementContent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.announcementContent = valueDes;
          break;
        case r'announcementId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.announcementId = valueDes;
          break;
        case r'readCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.readCount = valueDes;
          break;
        case r'totalRecipients':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalRecipients = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnnouncementReadStatResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnnouncementReadStatResponseBuilder();
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

