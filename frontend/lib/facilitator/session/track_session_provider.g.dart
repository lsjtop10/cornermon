// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TrackSession)
final trackSessionProvider = TrackSessionProvider._();

final class TrackSessionProvider
    extends $NotifierProvider<TrackSession, TrackSessionState> {
  TrackSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackSessionHash();

  @$internal
  @override
  TrackSession create() => TrackSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrackSessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrackSessionState>(value),
    );
  }
}

String _$trackSessionHash() => r'159a48af604bc857facc65b53d1d5302ebf88dab';

abstract class _$TrackSession extends $Notifier<TrackSessionState> {
  TrackSessionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TrackSessionState, TrackSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TrackSessionState, TrackSessionState>,
              TrackSessionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
