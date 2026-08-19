// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_read_stat_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AnnouncementReadStatResponse extends AnnouncementReadStatResponse {
  @override
  final String? announcementContent;
  @override
  final String? announcementId;
  @override
  final int? readCount;
  @override
  final int? totalRecipients;

  factory _$AnnouncementReadStatResponse(
          [void Function(AnnouncementReadStatResponseBuilder)? updates]) =>
      (AnnouncementReadStatResponseBuilder()..update(updates))._build();

  _$AnnouncementReadStatResponse._(
      {this.announcementContent,
      this.announcementId,
      this.readCount,
      this.totalRecipients})
      : super._();
  @override
  AnnouncementReadStatResponse rebuild(
          void Function(AnnouncementReadStatResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AnnouncementReadStatResponseBuilder toBuilder() =>
      AnnouncementReadStatResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AnnouncementReadStatResponse &&
        announcementContent == other.announcementContent &&
        announcementId == other.announcementId &&
        readCount == other.readCount &&
        totalRecipients == other.totalRecipients;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, announcementContent.hashCode);
    _$hash = $jc(_$hash, announcementId.hashCode);
    _$hash = $jc(_$hash, readCount.hashCode);
    _$hash = $jc(_$hash, totalRecipients.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AnnouncementReadStatResponse')
          ..add('announcementContent', announcementContent)
          ..add('announcementId', announcementId)
          ..add('readCount', readCount)
          ..add('totalRecipients', totalRecipients))
        .toString();
  }
}

class AnnouncementReadStatResponseBuilder
    implements
        Builder<AnnouncementReadStatResponse,
            AnnouncementReadStatResponseBuilder> {
  _$AnnouncementReadStatResponse? _$v;

  String? _announcementContent;
  String? get announcementContent => _$this._announcementContent;
  set announcementContent(String? announcementContent) =>
      _$this._announcementContent = announcementContent;

  String? _announcementId;
  String? get announcementId => _$this._announcementId;
  set announcementId(String? announcementId) =>
      _$this._announcementId = announcementId;

  int? _readCount;
  int? get readCount => _$this._readCount;
  set readCount(int? readCount) => _$this._readCount = readCount;

  int? _totalRecipients;
  int? get totalRecipients => _$this._totalRecipients;
  set totalRecipients(int? totalRecipients) =>
      _$this._totalRecipients = totalRecipients;

  AnnouncementReadStatResponseBuilder() {
    AnnouncementReadStatResponse._defaults(this);
  }

  AnnouncementReadStatResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _announcementContent = $v.announcementContent;
      _announcementId = $v.announcementId;
      _readCount = $v.readCount;
      _totalRecipients = $v.totalRecipients;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AnnouncementReadStatResponse other) {
    _$v = other as _$AnnouncementReadStatResponse;
  }

  @override
  void update(void Function(AnnouncementReadStatResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AnnouncementReadStatResponse build() => _build();

  _$AnnouncementReadStatResponse _build() {
    final _$result = _$v ??
        _$AnnouncementReadStatResponse._(
          announcementContent: announcementContent,
          announcementId: announcementId,
          readCount: readCount,
          totalRecipients: totalRecipients,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
