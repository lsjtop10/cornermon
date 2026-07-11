// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_direct_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TrackDirectActions)
final trackDirectActionsProvider = TrackDirectActionsFamily._();

final class TrackDirectActionsProvider
    extends $NotifierProvider<TrackDirectActions, void> {
  TrackDirectActionsProvider._({
    required TrackDirectActionsFamily super.from,
    required TrackId super.argument,
  }) : super(
         retry: null,
         name: r'trackDirectActionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trackDirectActionsHash();

  @override
  String toString() {
    return r'trackDirectActionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TrackDirectActions create() => TrackDirectActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TrackDirectActionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trackDirectActionsHash() =>
    r'2322bcd5ecbffe6819147036e5a144a90578a8ec';

final class TrackDirectActionsFamily extends $Family
    with $ClassFamilyOverride<TrackDirectActions, void, void, void, TrackId> {
  TrackDirectActionsFamily._()
    : super(
        retry: null,
        name: r'trackDirectActionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TrackDirectActionsProvider call(TrackId trackId) =>
      TrackDirectActionsProvider._(argument: trackId, from: this);

  @override
  String toString() => r'trackDirectActionsProvider';
}

abstract class _$TrackDirectActions extends $Notifier<void> {
  late final _$args = ref.$arg as TrackId;
  TrackId get trackId => _$args;

  void build(TrackId trackId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
