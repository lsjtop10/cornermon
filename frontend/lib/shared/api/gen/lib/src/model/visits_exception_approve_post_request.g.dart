// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visits_exception_approve_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VisitsExceptionApprovePostRequest
    extends VisitsExceptionApprovePostRequest {
  @override
  final String groupId;
  @override
  final String cornerId;

  factory _$VisitsExceptionApprovePostRequest([
    void Function(VisitsExceptionApprovePostRequestBuilder)? updates,
  ]) => (VisitsExceptionApprovePostRequestBuilder()..update(updates))._build();

  _$VisitsExceptionApprovePostRequest._({
    required this.groupId,
    required this.cornerId,
  }) : super._();
  @override
  VisitsExceptionApprovePostRequest rebuild(
    void Function(VisitsExceptionApprovePostRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  VisitsExceptionApprovePostRequestBuilder toBuilder() =>
      VisitsExceptionApprovePostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VisitsExceptionApprovePostRequest &&
        groupId == other.groupId &&
        cornerId == other.cornerId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, groupId.hashCode);
    _$hash = $jc(_$hash, cornerId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VisitsExceptionApprovePostRequest')
          ..add('groupId', groupId)
          ..add('cornerId', cornerId))
        .toString();
  }
}

class VisitsExceptionApprovePostRequestBuilder
    implements
        Builder<
          VisitsExceptionApprovePostRequest,
          VisitsExceptionApprovePostRequestBuilder
        > {
  _$VisitsExceptionApprovePostRequest? _$v;

  String? _groupId;
  String? get groupId => _$this._groupId;
  set groupId(String? groupId) => _$this._groupId = groupId;

  String? _cornerId;
  String? get cornerId => _$this._cornerId;
  set cornerId(String? cornerId) => _$this._cornerId = cornerId;

  VisitsExceptionApprovePostRequestBuilder() {
    VisitsExceptionApprovePostRequest._defaults(this);
  }

  VisitsExceptionApprovePostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _groupId = $v.groupId;
      _cornerId = $v.cornerId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VisitsExceptionApprovePostRequest other) {
    _$v = other as _$VisitsExceptionApprovePostRequest;
  }

  @override
  void update(
    void Function(VisitsExceptionApprovePostRequestBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  VisitsExceptionApprovePostRequest build() => _build();

  _$VisitsExceptionApprovePostRequest _build() {
    final _$result =
        _$v ??
        _$VisitsExceptionApprovePostRequest._(
          groupId: BuiltValueNullFieldError.checkNotNull(
            groupId,
            r'VisitsExceptionApprovePostRequest',
            'groupId',
          ),
          cornerId: BuiltValueNullFieldError.checkNotNull(
            cornerId,
            r'VisitsExceptionApprovePostRequest',
            'cornerId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
