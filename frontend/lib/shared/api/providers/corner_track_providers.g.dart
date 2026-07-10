// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corner_track_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cornerList)
final cornerListProvider = CornerListProvider._();

final class CornerListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Corner>>,
          List<Corner>,
          FutureOr<List<Corner>>
        >
    with $FutureModifier<List<Corner>>, $FutureProvider<List<Corner>> {
  CornerListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cornerListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cornerListHash();

  @$internal
  @override
  $FutureProviderElement<List<Corner>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Corner>> create(Ref ref) {
    return cornerList(ref);
  }
}

String _$cornerListHash() => r'b174c6be295f003cd7d27abee84402bea2c549d7';

@ProviderFor(cornerDetail)
final cornerDetailProvider = CornerDetailFamily._();

final class CornerDetailProvider
    extends $FunctionalProvider<AsyncValue<Corner>, Corner, FutureOr<Corner>>
    with $FutureModifier<Corner>, $FutureProvider<Corner> {
  CornerDetailProvider._({
    required CornerDetailFamily super.from,
    required CornerId super.argument,
  }) : super(
         retry: null,
         name: r'cornerDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cornerDetailHash();

  @override
  String toString() {
    return r'cornerDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Corner> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Corner> create(Ref ref) {
    final argument = this.argument as CornerId;
    return cornerDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CornerDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cornerDetailHash() => r'2a00fed776d4e564af8f9e0a24ef13bcc678282a';

final class CornerDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Corner>, CornerId> {
  CornerDetailFamily._()
    : super(
        retry: null,
        name: r'cornerDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CornerDetailProvider call(CornerId id) =>
      CornerDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'cornerDetailProvider';
}

@ProviderFor(trackList)
final trackListProvider = TrackListProvider._();

final class TrackListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Track>>,
          List<Track>,
          FutureOr<List<Track>>
        >
    with $FutureModifier<List<Track>>, $FutureProvider<List<Track>> {
  TrackListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackListHash();

  @$internal
  @override
  $FutureProviderElement<List<Track>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Track>> create(Ref ref) {
    return trackList(ref);
  }
}

String _$trackListHash() => r'9bbbad915df2132d440dbfb5e1dfa63781a54127';
