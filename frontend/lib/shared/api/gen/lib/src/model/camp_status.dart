//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'camp_status.g.dart';

class CampStatus extends EnumClass {

  /// - PENDING: 준비 중 (진행자 로그인 불가) - ACTIVE: 진행 중 (모든 기능 활성화) - ENDED: 종료 (리포트 조회만 허용) 
  @BuiltValueEnumConst(wireName: r'PENDING')
  static const CampStatus PENDING = _$PENDING;
  /// - PENDING: 준비 중 (진행자 로그인 불가) - ACTIVE: 진행 중 (모든 기능 활성화) - ENDED: 종료 (리포트 조회만 허용) 
  @BuiltValueEnumConst(wireName: r'ACTIVE')
  static const CampStatus ACTIVE = _$ACTIVE;
  /// - PENDING: 준비 중 (진행자 로그인 불가) - ACTIVE: 진행 중 (모든 기능 활성화) - ENDED: 종료 (리포트 조회만 허용) 
  @BuiltValueEnumConst(wireName: r'ENDED')
  static const CampStatus ENDED = _$ENDED;

  static Serializer<CampStatus> get serializer => _$campStatusSerializer;

  const CampStatus._(String name): super(name);

  static BuiltSet<CampStatus> get values => _$values;
  static CampStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class CampStatusMixin = Object with _$CampStatusMixin;

