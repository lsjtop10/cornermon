// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camp_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CampResponseStatusEnum _$campResponseStatusEnum_PENDING =
    const CampResponseStatusEnum._('PENDING');
const CampResponseStatusEnum _$campResponseStatusEnum_ACTIVE =
    const CampResponseStatusEnum._('ACTIVE');
const CampResponseStatusEnum _$campResponseStatusEnum_ENDED =
    const CampResponseStatusEnum._('ENDED');

CampResponseStatusEnum _$campResponseStatusEnumValueOf(String name) {
  switch (name) {
    case 'PENDING':
      return _$campResponseStatusEnum_PENDING;
    case 'ACTIVE':
      return _$campResponseStatusEnum_ACTIVE;
    case 'ENDED':
      return _$campResponseStatusEnum_ENDED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CampResponseStatusEnum> _$campResponseStatusEnumValues =
    BuiltSet<CampResponseStatusEnum>(const <CampResponseStatusEnum>[
  _$campResponseStatusEnum_PENDING,
  _$campResponseStatusEnum_ACTIVE,
  _$campResponseStatusEnum_ENDED,
]);

Serializer<CampResponseStatusEnum> _$campResponseStatusEnumSerializer =
    _$CampResponseStatusEnumSerializer();

class _$CampResponseStatusEnumSerializer
    implements PrimitiveSerializer<CampResponseStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PENDING': 'PENDING',
    'ACTIVE': 'ACTIVE',
    'ENDED': 'ENDED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PENDING': 'PENDING',
    'ACTIVE': 'ACTIVE',
    'ENDED': 'ENDED',
  };

  @override
  final Iterable<Type> types = const <Type>[CampResponseStatusEnum];
  @override
  final String wireName = 'CampResponseStatusEnum';

  @override
  Object serialize(Serializers serializers, CampResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CampResponseStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CampResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CampResponse extends CampResponse {
  @override
  final int? bottleneckMinSamples;
  @override
  final int? bottleneckRatioPct;
  @override
  final DateTime? endAt;
  @override
  final String? id;
  @override
  final String? name;
  @override
  final String? registrationCode;
  @override
  final DateTime? startAt;
  @override
  final CampResponseStatusEnum? status;

  factory _$CampResponse([void Function(CampResponseBuilder)? updates]) =>
      (CampResponseBuilder()..update(updates))._build();

  _$CampResponse._(
      {this.bottleneckMinSamples,
      this.bottleneckRatioPct,
      this.endAt,
      this.id,
      this.name,
      this.registrationCode,
      this.startAt,
      this.status})
      : super._();
  @override
  CampResponse rebuild(void Function(CampResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CampResponseBuilder toBuilder() => CampResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CampResponse &&
        bottleneckMinSamples == other.bottleneckMinSamples &&
        bottleneckRatioPct == other.bottleneckRatioPct &&
        endAt == other.endAt &&
        id == other.id &&
        name == other.name &&
        registrationCode == other.registrationCode &&
        startAt == other.startAt &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, bottleneckMinSamples.hashCode);
    _$hash = $jc(_$hash, bottleneckRatioPct.hashCode);
    _$hash = $jc(_$hash, endAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, registrationCode.hashCode);
    _$hash = $jc(_$hash, startAt.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CampResponse')
          ..add('bottleneckMinSamples', bottleneckMinSamples)
          ..add('bottleneckRatioPct', bottleneckRatioPct)
          ..add('endAt', endAt)
          ..add('id', id)
          ..add('name', name)
          ..add('registrationCode', registrationCode)
          ..add('startAt', startAt)
          ..add('status', status))
        .toString();
  }
}

class CampResponseBuilder
    implements Builder<CampResponse, CampResponseBuilder> {
  _$CampResponse? _$v;

  int? _bottleneckMinSamples;
  int? get bottleneckMinSamples => _$this._bottleneckMinSamples;
  set bottleneckMinSamples(int? bottleneckMinSamples) =>
      _$this._bottleneckMinSamples = bottleneckMinSamples;

  int? _bottleneckRatioPct;
  int? get bottleneckRatioPct => _$this._bottleneckRatioPct;
  set bottleneckRatioPct(int? bottleneckRatioPct) =>
      _$this._bottleneckRatioPct = bottleneckRatioPct;

  DateTime? _endAt;
  DateTime? get endAt => _$this._endAt;
  set endAt(DateTime? endAt) => _$this._endAt = endAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _registrationCode;
  String? get registrationCode => _$this._registrationCode;
  set registrationCode(String? registrationCode) =>
      _$this._registrationCode = registrationCode;

  DateTime? _startAt;
  DateTime? get startAt => _$this._startAt;
  set startAt(DateTime? startAt) => _$this._startAt = startAt;

  CampResponseStatusEnum? _status;
  CampResponseStatusEnum? get status => _$this._status;
  set status(CampResponseStatusEnum? status) => _$this._status = status;

  CampResponseBuilder() {
    CampResponse._defaults(this);
  }

  CampResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bottleneckMinSamples = $v.bottleneckMinSamples;
      _bottleneckRatioPct = $v.bottleneckRatioPct;
      _endAt = $v.endAt;
      _id = $v.id;
      _name = $v.name;
      _registrationCode = $v.registrationCode;
      _startAt = $v.startAt;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CampResponse other) {
    _$v = other as _$CampResponse;
  }

  @override
  void update(void Function(CampResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CampResponse build() => _build();

  _$CampResponse _build() {
    final _$result = _$v ??
        _$CampResponse._(
          bottleneckMinSamples: bottleneckMinSamples,
          bottleneckRatioPct: bottleneckRatioPct,
          endAt: endAt,
          id: id,
          name: name,
          registrationCode: registrationCode,
          startAt: startAt,
          status: status,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
