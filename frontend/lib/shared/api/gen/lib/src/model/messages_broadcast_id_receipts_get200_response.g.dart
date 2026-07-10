// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_broadcast_id_receipts_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MessagesBroadcastIdReceiptsGet200Response
    extends MessagesBroadcastIdReceiptsGet200Response {
  @override
  final BuiltList<BroadcastReceipt>? receipts;
  @override
  final double? readRate;

  factory _$MessagesBroadcastIdReceiptsGet200Response([
    void Function(MessagesBroadcastIdReceiptsGet200ResponseBuilder)? updates,
  ]) => (MessagesBroadcastIdReceiptsGet200ResponseBuilder()..update(updates))
      ._build();

  _$MessagesBroadcastIdReceiptsGet200Response._({this.receipts, this.readRate})
    : super._();
  @override
  MessagesBroadcastIdReceiptsGet200Response rebuild(
    void Function(MessagesBroadcastIdReceiptsGet200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MessagesBroadcastIdReceiptsGet200ResponseBuilder toBuilder() =>
      MessagesBroadcastIdReceiptsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MessagesBroadcastIdReceiptsGet200Response &&
        receipts == other.receipts &&
        readRate == other.readRate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, receipts.hashCode);
    _$hash = $jc(_$hash, readRate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'MessagesBroadcastIdReceiptsGet200Response',
          )
          ..add('receipts', receipts)
          ..add('readRate', readRate))
        .toString();
  }
}

class MessagesBroadcastIdReceiptsGet200ResponseBuilder
    implements
        Builder<
          MessagesBroadcastIdReceiptsGet200Response,
          MessagesBroadcastIdReceiptsGet200ResponseBuilder
        > {
  _$MessagesBroadcastIdReceiptsGet200Response? _$v;

  ListBuilder<BroadcastReceipt>? _receipts;
  ListBuilder<BroadcastReceipt> get receipts =>
      _$this._receipts ??= ListBuilder<BroadcastReceipt>();
  set receipts(ListBuilder<BroadcastReceipt>? receipts) =>
      _$this._receipts = receipts;

  double? _readRate;
  double? get readRate => _$this._readRate;
  set readRate(double? readRate) => _$this._readRate = readRate;

  MessagesBroadcastIdReceiptsGet200ResponseBuilder() {
    MessagesBroadcastIdReceiptsGet200Response._defaults(this);
  }

  MessagesBroadcastIdReceiptsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _receipts = $v.receipts?.toBuilder();
      _readRate = $v.readRate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MessagesBroadcastIdReceiptsGet200Response other) {
    _$v = other as _$MessagesBroadcastIdReceiptsGet200Response;
  }

  @override
  void update(
    void Function(MessagesBroadcastIdReceiptsGet200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  MessagesBroadcastIdReceiptsGet200Response build() => _build();

  _$MessagesBroadcastIdReceiptsGet200Response _build() {
    _$MessagesBroadcastIdReceiptsGet200Response _$result;
    try {
      _$result =
          _$v ??
          _$MessagesBroadcastIdReceiptsGet200Response._(
            receipts: _receipts?.build(),
            readRate: readRate,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'receipts';
        _receipts?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MessagesBroadcastIdReceiptsGet200Response',
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
