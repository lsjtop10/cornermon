// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camp.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Camp extends Camp {
  @override
  final String id;
  @override
  final String name;
  @override
  final DateTime startAt;
  @override
  final DateTime endAt;
  @override
  final CampStatus status;
  @override
  final int? bottleneckMinSamples;
  @override
  final int? bottleneckRatioPct;

  factory _$Camp([void Function(CampBuilder)? updates]) =>
      (CampBuilder()..update(updates))._build();

  _$Camp._(
      {required this.id,
      required this.name,
      required this.startAt,
      required this.endAt,
      required this.status,
      this.bottleneckMinSamples,
      this.bottleneckRatioPct})
      : super._();
  @override
  Camp rebuild(void Function(CampBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CampBuilder toBuilder() => CampBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Camp &&
        id == other.id &&
        name == other.name &&
        startAt == other.startAt &&
        endAt == other.endAt &&
        status == other.status &&
        bottleneckMinSamples == other.bottleneckMinSamples &&
        bottleneckRatioPct == other.bottleneckRatioPct;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, startAt.hashCode);
    _$hash = $jc(_$hash, endAt.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, bottleneckMinSamples.hashCode);
    _$hash = $jc(_$hash, bottleneckRatioPct.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Camp')
          ..add('id', id)
          ..add('name', name)
          ..add('startAt', startAt)
          ..add('endAt', endAt)
          ..add('status', status)
          ..add('bottleneckMinSamples', bottleneckMinSamples)
          ..add('bottleneckRatioPct', bottleneckRatioPct))
        .toString();
  }
}

class CampBuilder implements Builder<Camp, CampBuilder> {
  _$Camp? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DateTime? _startAt;
  DateTime? get startAt => _$this._startAt;
  set startAt(DateTime? startAt) => _$this._startAt = startAt;

  DateTime? _endAt;
  DateTime? get endAt => _$this._endAt;
  set endAt(DateTime? endAt) => _$this._endAt = endAt;

  CampStatus? _status;
  CampStatus? get status => _$this._status;
  set status(CampStatus? status) => _$this._status = status;

  int? _bottleneckMinSamples;
  int? get bottleneckMinSamples => _$this._bottleneckMinSamples;
  set bottleneckMinSamples(int? bottleneckMinSamples) =>
      _$this._bottleneckMinSamples = bottleneckMinSamples;

  int? _bottleneckRatioPct;
  int? get bottleneckRatioPct => _$this._bottleneckRatioPct;
  set bottleneckRatioPct(int? bottleneckRatioPct) =>
      _$this._bottleneckRatioPct = bottleneckRatioPct;

  CampBuilder() {
    Camp._defaults(this);
  }

  CampBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _startAt = $v.startAt;
      _endAt = $v.endAt;
      _status = $v.status;
      _bottleneckMinSamples = $v.bottleneckMinSamples;
      _bottleneckRatioPct = $v.bottleneckRatioPct;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Camp other) {
    _$v = other as _$Camp;
  }

  @override
  void update(void Function(CampBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Camp build() => _build();

  _$Camp _build() {
    final _$result = _$v ??
        _$Camp._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Camp', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(name, r'Camp', 'name'),
          startAt: BuiltValueNullFieldError.checkNotNull(
              startAt, r'Camp', 'startAt'),
          endAt: BuiltValueNullFieldError.checkNotNull(endAt, r'Camp', 'endAt'),
          status:
              BuiltValueNullFieldError.checkNotNull(status, r'Camp', 'status'),
          bottleneckMinSamples: bottleneckMinSamples,
          bottleneckRatioPct: bottleneckRatioPct,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
