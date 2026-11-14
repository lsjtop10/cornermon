// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(badgeList)
final badgeListProvider = BadgeListProvider._();

final class BadgeListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Badge>>,
          List<Badge>,
          FutureOr<List<Badge>>
        >
    with $FutureModifier<List<Badge>>, $FutureProvider<List<Badge>> {
  BadgeListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'badgeListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$badgeListHash();

  @$internal
  @override
  $FutureProviderElement<List<Badge>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Badge>> create(Ref ref) {
    return badgeList(ref);
  }
}

String _$badgeListHash() => r'3159372c1d0e8548b091090b4f58649853a37198';

@ProviderFor(bulkGenerateBadges)
final bulkGenerateBadgesProvider = BulkGenerateBadgesFamily._();

final class BulkGenerateBadgesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Badge>>,
          List<Badge>,
          FutureOr<List<Badge>>
        >
    with $FutureModifier<List<Badge>>, $FutureProvider<List<Badge>> {
  BulkGenerateBadgesProvider._({
    required BulkGenerateBadgesFamily super.from,
    required int super.argument,
  }) : super(
         retry: noRetry,
         name: r'bulkGenerateBadgesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bulkGenerateBadgesHash();

  @override
  String toString() {
    return r'bulkGenerateBadgesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Badge>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Badge>> create(Ref ref) {
    final argument = this.argument as int;
    return bulkGenerateBadges(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BulkGenerateBadgesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bulkGenerateBadgesHash() =>
    r'8129723ea5ff33f384bfdc2e5b73a4459c2f0512';

final class BulkGenerateBadgesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Badge>>, int> {
  BulkGenerateBadgesFamily._()
    : super(
        retry: noRetry,
        name: r'bulkGenerateBadgesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BulkGenerateBadgesProvider call(int count) =>
      BulkGenerateBadgesProvider._(argument: count, from: this);

  @override
  String toString() => r'bulkGenerateBadgesProvider';
}

@ProviderFor(exportUnassignedBadges)
final exportUnassignedBadgesProvider = ExportUnassignedBadgesProvider._();

final class ExportUnassignedBadgesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Badge>>,
          List<Badge>,
          FutureOr<List<Badge>>
        >
    with $FutureModifier<List<Badge>>, $FutureProvider<List<Badge>> {
  ExportUnassignedBadgesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportUnassignedBadgesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportUnassignedBadgesHash();

  @$internal
  @override
  $FutureProviderElement<List<Badge>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Badge>> create(Ref ref) {
    return exportUnassignedBadges(ref);
  }
}

String _$exportUnassignedBadgesHash() =>
    r'73fe153c21c58598c587ae927a7ceb414b5bcc11';

@ProviderFor(registerBadge)
final registerBadgeProvider = RegisterBadgeFamily._();

final class RegisterBadgeProvider
    extends $FunctionalProvider<AsyncValue<Badge>, Badge, FutureOr<Badge>>
    with $FutureModifier<Badge>, $FutureProvider<Badge> {
  RegisterBadgeProvider._({
    required RegisterBadgeFamily super.from,
    required (String, String, String) super.argument,
  }) : super(
         retry: noRetry,
         name: r'registerBadgeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$registerBadgeHash();

  @override
  String toString() {
    return r'registerBadgeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Badge> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Badge> create(Ref ref) {
    final argument = this.argument as (String, String, String);
    return registerBadge(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is RegisterBadgeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$registerBadgeHash() => r'2c1d1900f813bdf765a3cecf382707c600dce859';

final class RegisterBadgeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Badge>, (String, String, String)> {
  RegisterBadgeFamily._()
    : super(
        retry: noRetry,
        name: r'registerBadgeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RegisterBadgeProvider call(String badgeId, String campId, String groupName) =>
      RegisterBadgeProvider._(
        argument: (badgeId, campId, groupName),
        from: this,
      );

  @override
  String toString() => r'registerBadgeProvider';
}

@ProviderFor(scanRegisterBadge)
final scanRegisterBadgeProvider = ScanRegisterBadgeFamily._();

final class ScanRegisterBadgeProvider
    extends $FunctionalProvider<AsyncValue<Group>, Group, FutureOr<Group>>
    with $FutureModifier<Group>, $FutureProvider<Group> {
  ScanRegisterBadgeProvider._({
    required ScanRegisterBadgeFamily super.from,
    required (String, String, String) super.argument,
  }) : super(
         retry: noRetry,
         name: r'scanRegisterBadgeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$scanRegisterBadgeHash();

  @override
  String toString() {
    return r'scanRegisterBadgeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Group> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Group> create(Ref ref) {
    final argument = this.argument as (String, String, String);
    return scanRegisterBadge(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is ScanRegisterBadgeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$scanRegisterBadgeHash() => r'462d88fc33cafda003126c53862324dac825bd7d';

final class ScanRegisterBadgeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Group>, (String, String, String)> {
  ScanRegisterBadgeFamily._()
    : super(
        retry: noRetry,
        name: r'scanRegisterBadgeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ScanRegisterBadgeProvider call(
    String campId,
    String qrPayload,
    String groupName,
  ) => ScanRegisterBadgeProvider._(
    argument: (campId, qrPayload, groupName),
    from: this,
  );

  @override
  String toString() => r'scanRegisterBadgeProvider';
}
