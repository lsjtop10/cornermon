// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badges_scan_register_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BadgesScanRegisterPostRequest extends BadgesScanRegisterPostRequest {
  @override
  final String qrPayload;
  @override
  final String groupName;

  factory _$BadgesScanRegisterPostRequest(
          [void Function(BadgesScanRegisterPostRequestBuilder)? updates]) =>
      (BadgesScanRegisterPostRequestBuilder()..update(updates))._build();

  _$BadgesScanRegisterPostRequest._(
      {required this.qrPayload, required this.groupName})
      : super._();
  @override
  BadgesScanRegisterPostRequest rebuild(
          void Function(BadgesScanRegisterPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BadgesScanRegisterPostRequestBuilder toBuilder() =>
      BadgesScanRegisterPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BadgesScanRegisterPostRequest &&
        qrPayload == other.qrPayload &&
        groupName == other.groupName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, qrPayload.hashCode);
    _$hash = $jc(_$hash, groupName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BadgesScanRegisterPostRequest')
          ..add('qrPayload', qrPayload)
          ..add('groupName', groupName))
        .toString();
  }
}

class BadgesScanRegisterPostRequestBuilder
    implements
        Builder<BadgesScanRegisterPostRequest,
            BadgesScanRegisterPostRequestBuilder> {
  _$BadgesScanRegisterPostRequest? _$v;

  String? _qrPayload;
  String? get qrPayload => _$this._qrPayload;
  set qrPayload(String? qrPayload) => _$this._qrPayload = qrPayload;

  String? _groupName;
  String? get groupName => _$this._groupName;
  set groupName(String? groupName) => _$this._groupName = groupName;

  BadgesScanRegisterPostRequestBuilder() {
    BadgesScanRegisterPostRequest._defaults(this);
  }

  BadgesScanRegisterPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _qrPayload = $v.qrPayload;
      _groupName = $v.groupName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BadgesScanRegisterPostRequest other) {
    _$v = other as _$BadgesScanRegisterPostRequest;
  }

  @override
  void update(void Function(BadgesScanRegisterPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BadgesScanRegisterPostRequest build() => _build();

  _$BadgesScanRegisterPostRequest _build() {
    final _$result = _$v ??
        _$BadgesScanRegisterPostRequest._(
          qrPayload: BuiltValueNullFieldError.checkNotNull(
              qrPayload, r'BadgesScanRegisterPostRequest', 'qrPayload'),
          groupName: BuiltValueNullFieldError.checkNotNull(
              groupName, r'BadgesScanRegisterPostRequest', 'groupName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
