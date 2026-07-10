// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GroupStatus _$IDLE_MOVING = const GroupStatus._('IDLE_MOVING');
const GroupStatus _$AT_CORNER = const GroupStatus._('AT_CORNER');
const GroupStatus _$FINISHED = const GroupStatus._('FINISHED');

GroupStatus _$valueOf(String name) {
  switch (name) {
    case 'IDLE_MOVING':
      return _$IDLE_MOVING;
    case 'AT_CORNER':
      return _$AT_CORNER;
    case 'FINISHED':
      return _$FINISHED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GroupStatus> _$values = BuiltSet<GroupStatus>(
  const <GroupStatus>[_$IDLE_MOVING, _$AT_CORNER, _$FINISHED],
);

class _$GroupStatusMeta {
  const _$GroupStatusMeta();
  GroupStatus get IDLE_MOVING => _$IDLE_MOVING;
  GroupStatus get AT_CORNER => _$AT_CORNER;
  GroupStatus get FINISHED => _$FINISHED;
  GroupStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<GroupStatus> get values => _$values;
}

mixin _$GroupStatusMixin {
  // ignore: non_constant_identifier_names
  _$GroupStatusMeta get GroupStatus => const _$GroupStatusMeta();
}

Serializer<GroupStatus> _$groupStatusSerializer = _$GroupStatusSerializer();

class _$GroupStatusSerializer implements PrimitiveSerializer<GroupStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'IDLE_MOVING': 'IDLE_MOVING',
    'AT_CORNER': 'AT_CORNER',
    'FINISHED': 'FINISHED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'IDLE_MOVING': 'IDLE_MOVING',
    'AT_CORNER': 'AT_CORNER',
    'FINISHED': 'FINISHED',
  };

  @override
  final Iterable<Type> types = const <Type>[GroupStatus];
  @override
  final String wireName = 'GroupStatus';

  @override
  Object serialize(
    Serializers serializers,
    GroupStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  GroupStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GroupStatus.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
