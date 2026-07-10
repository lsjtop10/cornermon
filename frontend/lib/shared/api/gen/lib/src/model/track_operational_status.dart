//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'track_operational_status.g.dart';

class TrackOperationalStatus extends EnumClass {

  @BuiltValueEnumConst(wireName: r'IDLE')
  static const TrackOperationalStatus IDLE = _$IDLE;
  @BuiltValueEnumConst(wireName: r'BUSY')
  static const TrackOperationalStatus BUSY = _$BUSY;

  static Serializer<TrackOperationalStatus> get serializer => _$trackOperationalStatusSerializer;

  const TrackOperationalStatus._(String name): super(name);

  static BuiltSet<TrackOperationalStatus> get values => _$values;
  static TrackOperationalStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class TrackOperationalStatusMixin = Object with _$TrackOperationalStatusMixin;

