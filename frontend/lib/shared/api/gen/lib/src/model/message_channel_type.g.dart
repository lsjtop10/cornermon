// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_channel_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MessageChannelType _$BROADCAST = const MessageChannelType._('BROADCAST');
const MessageChannelType _$DIRECT = const MessageChannelType._('DIRECT');

MessageChannelType _$valueOf(String name) {
  switch (name) {
    case 'BROADCAST':
      return _$BROADCAST;
    case 'DIRECT':
      return _$DIRECT;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MessageChannelType> _$values =
    BuiltSet<MessageChannelType>(const <MessageChannelType>[
  _$BROADCAST,
  _$DIRECT,
]);

class _$MessageChannelTypeMeta {
  const _$MessageChannelTypeMeta();
  MessageChannelType get BROADCAST => _$BROADCAST;
  MessageChannelType get DIRECT => _$DIRECT;
  MessageChannelType valueOf(String name) => _$valueOf(name);
  BuiltSet<MessageChannelType> get values => _$values;
}

abstract class _$MessageChannelTypeMixin {
  // ignore: non_constant_identifier_names
  _$MessageChannelTypeMeta get MessageChannelType =>
      const _$MessageChannelTypeMeta();
}

Serializer<MessageChannelType> _$messageChannelTypeSerializer =
    _$MessageChannelTypeSerializer();

class _$MessageChannelTypeSerializer
    implements PrimitiveSerializer<MessageChannelType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'BROADCAST': 'BROADCAST',
    'DIRECT': 'DIRECT',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'BROADCAST': 'BROADCAST',
    'DIRECT': 'DIRECT',
  };

  @override
  final Iterable<Type> types = const <Type>[MessageChannelType];
  @override
  final String wireName = 'MessageChannelType';

  @override
  Object serialize(Serializers serializers, MessageChannelType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MessageChannelType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MessageChannelType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
