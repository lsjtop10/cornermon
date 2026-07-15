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
          BResourceManagementAdminApi,
          BResourceManagementAdminApi,
          BResourceManagementAdminApi
        >
    with $Provider<BResourceManagementAdminApi> {
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
  $ProviderElement<BResourceManagementAdminApi> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BResourceManagementAdminApi create(Ref ref) {
    return campApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BResourceManagementAdminApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BResourceManagementAdminApi>(value),
    );
  }
}

String _$campApiHash() => r'65ecb5f892b27813d989fb747515363de2027955';

@ProviderFor(campList)
final campListProvider = CampListProvider._();

final class CampListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Camp>>,
          List<Camp>,
          FutureOr<List<Camp>>
        >
    with $FutureModifier<List<Camp>>, $FutureProvider<List<Camp>> {
  CampListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'campListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$campListHash();

  @$internal
  @override
  $FutureProviderElement<List<Camp>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Camp>> create(Ref ref) {
    return campList(ref);
  }
}

String _$campListHash() => r'7a433bb993936447ba66cf2c4393a5b379927a5c';

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

@ProviderFor(createCamp)
final createCampProvider = CreateCampFamily._();

final class CreateCampProvider
    extends $FunctionalProvider<AsyncValue<Camp>, Camp, FutureOr<Camp>>
    with $FutureModifier<Camp>, $FutureProvider<Camp> {
  CreateCampProvider._({
    required CreateCampFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'createCampProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$createCampHash();

  @override
  String toString() {
    return r'createCampProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Camp> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Camp> create(Ref ref) {
    final argument = this.argument as String;
    return createCamp(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CreateCampProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$createCampHash() => r'ac6b77f9194aa83923717dcdebb93e4a2cf9d45e';

final class CreateCampFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Camp>, String> {
  CreateCampFamily._()
    : super(
        retry: null,
        name: r'createCampProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreateCampProvider call(String name) =>
      CreateCampProvider._(argument: name, from: this);

  @override
  String toString() => r'createCampProvider';
}

@ProviderFor(updateCamp)
final updateCampProvider = UpdateCampFamily._();

final class UpdateCampProvider
    extends $FunctionalProvider<AsyncValue<Camp>, Camp, FutureOr<Camp>>
    with $FutureModifier<Camp>, $FutureProvider<Camp> {
  UpdateCampProvider._({
    required UpdateCampFamily super.from,
    required (
      CampId, {
      String? name,
      int? bottleneckMinSamples,
      int? bottleneckRatioPct,
      DateTime? startAt,
      DateTime? endAt,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'updateCampProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$updateCampHash();

  @override
  String toString() {
    return r'updateCampProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Camp> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Camp> create(Ref ref) {
    final argument =
        this.argument
            as (
              CampId, {
              String? name,
              int? bottleneckMinSamples,
              int? bottleneckRatioPct,
              DateTime? startAt,
              DateTime? endAt,
            });
    return updateCamp(
      ref,
      argument.$1,
      name: argument.name,
      bottleneckMinSamples: argument.bottleneckMinSamples,
      bottleneckRatioPct: argument.bottleneckRatioPct,
      startAt: argument.startAt,
      endAt: argument.endAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateCampProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateCampHash() => r'b6b318daf7e4675709bb08e36544e6418e93d7bd';

final class UpdateCampFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Camp>,
          (
            CampId, {
            String? name,
            int? bottleneckMinSamples,
            int? bottleneckRatioPct,
            DateTime? startAt,
            DateTime? endAt,
          })
        > {
  UpdateCampFamily._()
    : super(
        retry: null,
        name: r'updateCampProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UpdateCampProvider call(
    CampId id, {
    String? name,
    int? bottleneckMinSamples,
    int? bottleneckRatioPct,
    DateTime? startAt,
    DateTime? endAt,
  }) => UpdateCampProvider._(
    argument: (
      id,
      name: name,
      bottleneckMinSamples: bottleneckMinSamples,
      bottleneckRatioPct: bottleneckRatioPct,
      startAt: startAt,
      endAt: endAt,
    ),
    from: this,
  );

  @override
  String toString() => r'updateCampProvider';
}

@ProviderFor(startCamp)
final startCampProvider = StartCampFamily._();

final class StartCampProvider
    extends $FunctionalProvider<AsyncValue<Camp>, Camp, FutureOr<Camp>>
    with $FutureModifier<Camp>, $FutureProvider<Camp> {
  StartCampProvider._({
    required StartCampFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: null,
         name: r'startCampProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$startCampHash();

  @override
  String toString() {
    return r'startCampProvider'
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
    return startCamp(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StartCampProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$startCampHash() => r'b5651bfc834a8af6f91768cc8258cbabe592af5c';

final class StartCampFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Camp>, CampId> {
  StartCampFamily._()
    : super(
        retry: null,
        name: r'startCampProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StartCampProvider call(CampId id) =>
      StartCampProvider._(argument: id, from: this);

  @override
  String toString() => r'startCampProvider';
}

@ProviderFor(endCamp)
final endCampProvider = EndCampFamily._();

final class EndCampProvider
    extends $FunctionalProvider<AsyncValue<Camp>, Camp, FutureOr<Camp>>
    with $FutureModifier<Camp>, $FutureProvider<Camp> {
  EndCampProvider._({
    required EndCampFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: null,
         name: r'endCampProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$endCampHash();

  @override
  String toString() {
    return r'endCampProvider'
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
    return endCamp(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EndCampProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$endCampHash() => r'ec080dfe26e119187472818f1e6695886a8bd248';

final class EndCampFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Camp>, CampId> {
  EndCampFamily._()
    : super(
        retry: null,
        name: r'endCampProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EndCampProvider call(CampId id) =>
      EndCampProvider._(argument: id, from: this);

  @override
  String toString() => r'endCampProvider';
}
