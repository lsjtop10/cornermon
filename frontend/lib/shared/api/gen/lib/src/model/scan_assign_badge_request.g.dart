// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'scan_assign_badge_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ScanAssignBadgeRequest extends ScanAssignBadgeRequest {
  @override
  final String? groupName;
  @override
  final String? qrPayload;

  factory _$ScanAssignBadgeRequest(
          [void Function(ScanAssignBadgeRequestBuilder)? updates]) =>
      (ScanAssignBadgeRequestBuilder()..update(updates))._build();

  _$ScanAssignBadgeRequest._({this.groupName, this.qrPayload}) : super._();
  @override
  ScanAssignBadgeRequest rebuild(
          void Function(ScanAssignBadgeRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ScanAssignBadgeRequestBuilder toBuilder() =>
      ScanAssignBadgeRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ScanAssignBadgeRequest &&
        groupName == other.groupName &&
        qrPayload == other.qrPayload;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, groupName.hashCode);
    _$hash = $jc(_$hash, qrPayload.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ScanAssignBadgeRequest')
          ..add('groupName', groupName)
          ..add('qrPayload', qrPayload))
        .toString();
  }
}

class ScanAssignBadgeRequestBuilder
    implements Builder<ScanAssignBadgeRequest, ScanAssignBadgeRequestBuilder> {
  _$ScanAssignBadgeRequest? _$v;

  String? _groupName;
  String? get groupName => _$this._groupName;
  set groupName(String? groupName) => _$this._groupName = groupName;

  String? _qrPayload;
  String? get qrPayload => _$this._qrPayload;
  set qrPayload(String? qrPayload) => _$this._qrPayload = qrPayload;

  ScanAssignBadgeRequestBuilder() {
    ScanAssignBadgeRequest._defaults(this);
  }

  ScanAssignBadgeRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _groupName = $v.groupName;
      _qrPayload = $v.qrPayload;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ScanAssignBadgeRequest other) {
    _$v = other as _$ScanAssignBadgeRequest;
  }

  @override
  void update(void Function(ScanAssignBadgeRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ScanAssignBadgeRequest build() => _build();

  _$ScanAssignBadgeRequest _build() {
    final _$result = _$v ??
        _$ScanAssignBadgeRequest._(
          groupName: groupName,
          qrPayload: qrPayload,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
