//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'group_status.g.dart';

class GroupStatus extends EnumClass {

  /// - IDLE_MOVING: 이동 중 - AT_CORNER: 특정 코너에서 진행 중 - FINISHED: 완주 
  @BuiltValueEnumConst(wireName: r'IDLE_MOVING')
  static const GroupStatus IDLE_MOVING = _$IDLE_MOVING;
  /// - IDLE_MOVING: 이동 중 - AT_CORNER: 특정 코너에서 진행 중 - FINISHED: 완주 
  @BuiltValueEnumConst(wireName: r'AT_CORNER')
  static const GroupStatus AT_CORNER = _$AT_CORNER;
  /// - IDLE_MOVING: 이동 중 - AT_CORNER: 특정 코너에서 진행 중 - FINISHED: 완주 
  @BuiltValueEnumConst(wireName: r'FINISHED')
  static const GroupStatus FINISHED = _$FINISHED;

  static Serializer<GroupStatus> get serializer => _$groupStatusSerializer;

  const GroupStatus._(String name): super(name);

  static BuiltSet<GroupStatus> get values => _$values;
  static GroupStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class GroupStatusMixin = Object with _$GroupStatusMixin;

