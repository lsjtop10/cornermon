// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broadcast_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedBroadcastId)
final selectedBroadcastIdProvider = SelectedBroadcastIdProvider._();

final class SelectedBroadcastIdProvider
    extends $NotifierProvider<SelectedBroadcastId, MessageId?> {
  SelectedBroadcastIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedBroadcastIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedBroadcastIdHash();

  @$internal
  @override
  SelectedBroadcastId create() => SelectedBroadcastId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MessageId? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MessageId?>(value),
    );
  }
}

String _$selectedBroadcastIdHash() =>
    r'c4f9743db3fd2950a88aadb38459bd1e0b90a601';

abstract class _$SelectedBroadcastId extends $Notifier<MessageId?> {
  MessageId? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MessageId?, MessageId?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MessageId?, MessageId?>,
              MessageId?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
