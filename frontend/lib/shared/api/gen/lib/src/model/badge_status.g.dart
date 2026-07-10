// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BadgeStatus _$UNASSIGNED = const BadgeStatus._('UNASSIGNED');
const BadgeStatus _$ASSIGNED = const BadgeStatus._('ASSIGNED');

BadgeStatus _$valueOf(String name) {
  switch (name) {
    case 'UNASSIGNED':
      return _$UNASSIGNED;
    case 'ASSIGNED':
      return _$ASSIGNED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BadgeStatus> _$values =
    BuiltSet<BadgeStatus>(const <BadgeStatus>[
  _$UNASSIGNED,
  _$ASSIGNED,
]);

class _$BadgeStatusMeta {
  const _$BadgeStatusMeta();
  BadgeStatus get UNASSIGNED => _$UNASSIGNED;
  BadgeStatus get ASSIGNED => _$ASSIGNED;
  BadgeStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<BadgeStatus> get values => _$values;
}

abstract class _$BadgeStatusMixin {
  // ignore: non_constant_identifier_names
  _$BadgeStatusMeta get BadgeStatus => const _$BadgeStatusMeta();
}

Serializer<BadgeStatus> _$badgeStatusSerializer = _$BadgeStatusSerializer();

class _$BadgeStatusSerializer implements PrimitiveSerializer<BadgeStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'UNASSIGNED': 'UNASSIGNED',
    'ASSIGNED': 'ASSIGNED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'UNASSIGNED': 'UNASSIGNED',
    'ASSIGNED': 'ASSIGNED',
  };

  @override
  final Iterable<Type> types = const <Type>[BadgeStatus];
  @override
  final String wireName = 'BadgeStatus';

  @override
  Object serialize(Serializers serializers, BadgeStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BadgeStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BadgeStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
