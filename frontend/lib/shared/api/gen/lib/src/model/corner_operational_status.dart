//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'corner_operational_status.g.dart';

class CornerOperationalStatus extends EnumClass {

  /// - INACTIVE: 미가동 (활성 트랙 0개) - IDLE: 유휴 (활성 트랙 있으나 진행중인 방문 없음) - BUSY: 동작 중 (진행중인 방문 있음) 
  @BuiltValueEnumConst(wireName: r'INACTIVE')
  static const CornerOperationalStatus INACTIVE = _$INACTIVE;
  /// - INACTIVE: 미가동 (활성 트랙 0개) - IDLE: 유휴 (활성 트랙 있으나 진행중인 방문 없음) - BUSY: 동작 중 (진행중인 방문 있음) 
  @BuiltValueEnumConst(wireName: r'IDLE')
  static const CornerOperationalStatus IDLE = _$IDLE;
  /// - INACTIVE: 미가동 (활성 트랙 0개) - IDLE: 유휴 (활성 트랙 있으나 진행중인 방문 없음) - BUSY: 동작 중 (진행중인 방문 있음) 
  @BuiltValueEnumConst(wireName: r'BUSY')
  static const CornerOperationalStatus BUSY = _$BUSY;

  static Serializer<CornerOperationalStatus> get serializer => _$cornerOperationalStatusSerializer;

  const CornerOperationalStatus._(String name): super(name);

  static BuiltSet<CornerOperationalStatus> get values => _$values;
  static CornerOperationalStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class CornerOperationalStatusMixin = Object with _$CornerOperationalStatusMixin;

