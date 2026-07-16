// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GroupResponseStatusEnum _$groupResponseStatusEnum_IDLE_MOVING =
    const GroupResponseStatusEnum._('IDLE_MOVING');
const GroupResponseStatusEnum _$groupResponseStatusEnum_AT_CORNER =
    const GroupResponseStatusEnum._('AT_CORNER');
const GroupResponseStatusEnum _$groupResponseStatusEnum_FINISHED =
    const GroupResponseStatusEnum._('FINISHED');

GroupResponseStatusEnum _$groupResponseStatusEnumValueOf(String name) {
  switch (name) {
    case 'IDLE_MOVING':
      return _$groupResponseStatusEnum_IDLE_MOVING;
    case 'AT_CORNER':
      return _$groupResponseStatusEnum_AT_CORNER;
    case 'FINISHED':
      return _$groupResponseStatusEnum_FINISHED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GroupResponseStatusEnum> _$groupResponseStatusEnumValues =
    BuiltSet<GroupResponseStatusEnum>(const <GroupResponseStatusEnum>[
  _$groupResponseStatusEnum_IDLE_MOVING,
  _$groupResponseStatusEnum_AT_CORNER,
  _$groupResponseStatusEnum_FINISHED,
]);

Serializer<GroupResponseStatusEnum> _$groupResponseStatusEnumSerializer =
    _$GroupResponseStatusEnumSerializer();

class _$GroupResponseStatusEnumSerializer
    implements PrimitiveSerializer<GroupResponseStatusEnum> {
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
  final Iterable<Type> types = const <Type>[GroupResponseStatusEnum];
  @override
  final String wireName = 'GroupResponseStatusEnum';

  @override
  Object serialize(Serializers serializers, GroupResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GroupResponseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GroupResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GroupResponse extends GroupResponse {
  @override
  final String? badgeId;
  @override
  final String? id;
  @override
  final bool? isFinished;
  @override
  final BuiltList<CornerProgressResponse>? itinerary;
  @override
  final String? name;
  @override
  final GroupResponseStatusEnum? status;

  factory _$GroupResponse([void Function(GroupResponseBuilder)? updates]) =>
      (GroupResponseBuilder()..update(updates))._build();

  _$GroupResponse._(
      {this.badgeId,
      this.id,
      this.isFinished,
      this.itinerary,
      this.name,
      this.status})
      : super._();
  @override
  GroupResponse rebuild(void Function(GroupResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GroupResponseBuilder toBuilder() => GroupResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GroupResponse &&
        badgeId == other.badgeId &&
        id == other.id &&
        isFinished == other.isFinished &&
        itinerary == other.itinerary &&
        name == other.name &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, badgeId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, isFinished.hashCode);
    _$hash = $jc(_$hash, itinerary.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GroupResponse')
          ..add('badgeId', badgeId)
          ..add('id', id)
          ..add('isFinished', isFinished)
          ..add('itinerary', itinerary)
          ..add('name', name)
          ..add('status', status))
        .toString();
  }
}

class GroupResponseBuilder
    implements Builder<GroupResponse, GroupResponseBuilder> {
  _$GroupResponse? _$v;

  String? _badgeId;
  String? get badgeId => _$this._badgeId;
  set badgeId(String? badgeId) => _$this._badgeId = badgeId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  bool? _isFinished;
  bool? get isFinished => _$this._isFinished;
  set isFinished(bool? isFinished) => _$this._isFinished = isFinished;

  ListBuilder<CornerProgressResponse>? _itinerary;
  ListBuilder<CornerProgressResponse> get itinerary =>
      _$this._itinerary ??= ListBuilder<CornerProgressResponse>();
  set itinerary(ListBuilder<CornerProgressResponse>? itinerary) =>
      _$this._itinerary = itinerary;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  GroupResponseStatusEnum? _status;
  GroupResponseStatusEnum? get status => _$this._status;
  set status(GroupResponseStatusEnum? status) => _$this._status = status;

  GroupResponseBuilder() {
    GroupResponse._defaults(this);
  }

  GroupResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _badgeId = $v.badgeId;
      _id = $v.id;
      _isFinished = $v.isFinished;
      _itinerary = $v.itinerary?.toBuilder();
      _name = $v.name;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GroupResponse other) {
    _$v = other as _$GroupResponse;
  }

  @override
  void update(void Function(GroupResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GroupResponse build() => _build();

  _$GroupResponse _build() {
    _$GroupResponse _$result;
    try {
      _$result = _$v ??
          _$GroupResponse._(
            badgeId: badgeId,
            id: id,
            isFinished: isFinished,
            itinerary: _itinerary?.build(),
            name: name,
            status: status,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'itinerary';
        _itinerary?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GroupResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
