// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'track_pin_export_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackPINExportResponse extends TrackPINExportResponse {
  @override
  final String? cornerName;
  @override
  final String? pin;
  @override
  final int? trackNo;

  factory _$TrackPINExportResponse(
          [void Function(TrackPINExportResponseBuilder)? updates]) =>
      (TrackPINExportResponseBuilder()..update(updates))._build();

  _$TrackPINExportResponse._({this.cornerName, this.pin, this.trackNo})
      : super._();
  @override
  TrackPINExportResponse rebuild(
          void Function(TrackPINExportResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackPINExportResponseBuilder toBuilder() =>
      TrackPINExportResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackPINExportResponse &&
        cornerName == other.cornerName &&
        pin == other.pin &&
        trackNo == other.trackNo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cornerName.hashCode);
    _$hash = $jc(_$hash, pin.hashCode);
    _$hash = $jc(_$hash, trackNo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackPINExportResponse')
          ..add('cornerName', cornerName)
          ..add('pin', pin)
          ..add('trackNo', trackNo))
        .toString();
  }
}

class TrackPINExportResponseBuilder
    implements Builder<TrackPINExportResponse, TrackPINExportResponseBuilder> {
  _$TrackPINExportResponse? _$v;

  String? _cornerName;
  String? get cornerName => _$this._cornerName;
  set cornerName(String? cornerName) => _$this._cornerName = cornerName;

  String? _pin;
  String? get pin => _$this._pin;
  set pin(String? pin) => _$this._pin = pin;

  int? _trackNo;
  int? get trackNo => _$this._trackNo;
  set trackNo(int? trackNo) => _$this._trackNo = trackNo;

  TrackPINExportResponseBuilder() {
    TrackPINExportResponse._defaults(this);
  }

  TrackPINExportResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cornerName = $v.cornerName;
      _pin = $v.pin;
      _trackNo = $v.trackNo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackPINExportResponse other) {
    _$v = other as _$TrackPINExportResponse;
  }

  @override
  void update(void Function(TrackPINExportResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackPINExportResponse build() => _build();

  _$TrackPINExportResponse _build() {
    final _$result = _$v ??
        _$TrackPINExportResponse._(
          cornerName: cornerName,
          pin: pin,
          trackNo: trackNo,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
