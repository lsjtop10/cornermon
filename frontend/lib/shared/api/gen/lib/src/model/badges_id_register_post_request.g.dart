// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badges_id_register_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BadgesIdRegisterPostRequest extends BadgesIdRegisterPostRequest {
  @override
  final String groupName;

  factory _$BadgesIdRegisterPostRequest(
          [void Function(BadgesIdRegisterPostRequestBuilder)? updates]) =>
      (BadgesIdRegisterPostRequestBuilder()..update(updates))._build();

  _$BadgesIdRegisterPostRequest._({required this.groupName}) : super._();
  @override
  BadgesIdRegisterPostRequest rebuild(
          void Function(BadgesIdRegisterPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BadgesIdRegisterPostRequestBuilder toBuilder() =>
      BadgesIdRegisterPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BadgesIdRegisterPostRequest && groupName == other.groupName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, groupName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BadgesIdRegisterPostRequest')
          ..add('groupName', groupName))
        .toString();
  }
}

class BadgesIdRegisterPostRequestBuilder
    implements
        Builder<BadgesIdRegisterPostRequest,
            BadgesIdRegisterPostRequestBuilder> {
  _$BadgesIdRegisterPostRequest? _$v;

  String? _groupName;
  String? get groupName => _$this._groupName;
  set groupName(String? groupName) => _$this._groupName = groupName;

  BadgesIdRegisterPostRequestBuilder() {
    BadgesIdRegisterPostRequest._defaults(this);
  }

  BadgesIdRegisterPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _groupName = $v.groupName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BadgesIdRegisterPostRequest other) {
    _$v = other as _$BadgesIdRegisterPostRequest;
  }

  @override
  void update(void Function(BadgesIdRegisterPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BadgesIdRegisterPostRequest build() => _build();

  _$BadgesIdRegisterPostRequest _build() {
    final _$result = _$v ??
        _$BadgesIdRegisterPostRequest._(
          groupName: BuiltValueNullFieldError.checkNotNull(
              groupName, r'BadgesIdRegisterPostRequest', 'groupName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
