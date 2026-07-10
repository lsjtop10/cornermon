// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camp_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(campApi)
final campApiProvider = CampApiProvider._();

final class CampApiProvider
    extends
        $FunctionalProvider<
          BCampCornerTrackApi,
          BCampCornerTrackApi,
          BCampCornerTrackApi
        >
    with $Provider<BCampCornerTrackApi> {
  CampApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'campApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$campApiHash();

  @$internal
  @override
  $ProviderElement<BCampCornerTrackApi> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BCampCornerTrackApi create(Ref ref) {
    return campApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BCampCornerTrackApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BCampCornerTrackApi>(value),
    );
  }
}

String _$campApiHash() => r'd899e0f180d7e6c17f0073856e2e1c1baf9899b1';

@ProviderFor(campList)
final campListProvider = CampListFamily._();

final class CampListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Camp>>,
          List<Camp>,
          FutureOr<List<Camp>>
        >
    with $FutureModifier<List<Camp>>, $FutureProvider<List<Camp>> {
  CampListProvider._({
    required CampListFamily super.from,
    required CampStatus? super.argument,
  }) : super(
         retry: null,
         name: r'campListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$campListHash();

  @override
  String toString() {
    return r'campListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Camp>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Camp>> create(Ref ref) {
    final argument = this.argument as CampStatus?;
    return campList(ref, status: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CampListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$campListHash() => r'0e833c572bff278e58ecec0247e9a136fca8f809';

final class CampListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Camp>>, CampStatus?> {
  CampListFamily._()
    : super(
        retry: null,
        name: r'campListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CampListProvider call({CampStatus? status}) =>
      CampListProvider._(argument: status, from: this);

  @override
  String toString() => r'campListProvider';
}

@ProviderFor(campDetail)
final campDetailProvider = CampDetailFamily._();

final class CampDetailProvider
    extends $FunctionalProvider<AsyncValue<Camp>, Camp, FutureOr<Camp>>
    with $FutureModifier<Camp>, $FutureProvider<Camp> {
  CampDetailProvider._({
    required CampDetailFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: null,
         name: r'campDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$campDetailHash();

  @override
  String toString() {
    return r'campDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Camp> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Camp> create(Ref ref) {
    final argument = this.argument as CampId;
    return campDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CampDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$campDetailHash() => r'78d465f45be078b937bc48beccb2b6e9fc46c674';

final class CampDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Camp>, CampId> {
  CampDetailFamily._()
    : super(
        retry: null,
        name: r'campDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CampDetailProvider call(CampId id) =>
      CampDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'campDetailProvider';
}
