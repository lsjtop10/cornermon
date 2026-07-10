// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Corner extends Corner {
  @override
  final String id;
  @override
  final String name;
  @override
  final int targetMinutes;
  @override
  final CornerOperationalStatus status;
  @override
  final bool? isBottleneck;
  @override
  final BuiltList<TrackSummary>? activeTracks;

  factory _$Corner([void Function(CornerBuilder)? updates]) =>
      (CornerBuilder()..update(updates))._build();

  _$Corner._({
    required this.id,
    required this.name,
    required this.targetMinutes,
    required this.status,
    this.isBottleneck,
    this.activeTracks,
  }) : super._();
  @override
  Corner rebuild(void Function(CornerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CornerBuilder toBuilder() => CornerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Corner &&
        id == other.id &&
        name == other.name &&
        targetMinutes == other.targetMinutes &&
        status == other.status &&
        isBottleneck == other.isBottleneck &&
        activeTracks == other.activeTracks;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, targetMinutes.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, isBottleneck.hashCode);
    _$hash = $jc(_$hash, activeTracks.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Corner')
          ..add('id', id)
          ..add('name', name)
          ..add('targetMinutes', targetMinutes)
          ..add('status', status)
          ..add('isBottleneck', isBottleneck)
          ..add('activeTracks', activeTracks))
        .toString();
  }
}

class CornerBuilder implements Builder<Corner, CornerBuilder> {
  _$Corner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _targetMinutes;
  int? get targetMinutes => _$this._targetMinutes;
  set targetMinutes(int? targetMinutes) =>
      _$this._targetMinutes = targetMinutes;

  CornerOperationalStatus? _status;
  CornerOperationalStatus? get status => _$this._status;
  set status(CornerOperationalStatus? status) => _$this._status = status;

  bool? _isBottleneck;
  bool? get isBottleneck => _$this._isBottleneck;
  set isBottleneck(bool? isBottleneck) => _$this._isBottleneck = isBottleneck;

  ListBuilder<TrackSummary>? _activeTracks;
  ListBuilder<TrackSummary> get activeTracks =>
      _$this._activeTracks ??= ListBuilder<TrackSummary>();
  set activeTracks(ListBuilder<TrackSummary>? activeTracks) =>
      _$this._activeTracks = activeTracks;

  CornerBuilder() {
    Corner._defaults(this);
  }

  CornerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _targetMinutes = $v.targetMinutes;
      _status = $v.status;
      _isBottleneck = $v.isBottleneck;
      _activeTracks = $v.activeTracks?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Corner other) {
    _$v = other as _$Corner;
  }

  @override
  void update(void Function(CornerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Corner build() => _build();

  _$Corner _build() {
    _$Corner _$result;
    try {
      _$result =
          _$v ??
          _$Corner._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Corner', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'Corner',
              'name',
            ),
            targetMinutes: BuiltValueNullFieldError.checkNotNull(
              targetMinutes,
              r'Corner',
              'targetMinutes',
            ),
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'Corner',
              'status',
            ),
            isBottleneck: isBottleneck,
            activeTracks: _activeTracks?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'activeTracks';
        _activeTracks?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'Corner',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
