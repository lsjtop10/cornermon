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
         retry: null,
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
    r'fd3d92b2e7cab41d7e81e32a8b751fa0e2732d49';

final class BulkGenerateBadgesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Badge>>, int> {
  BulkGenerateBadgesFamily._()
    : super(
        retry: null,
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
    required (String, String) super.argument,
  }) : super(
         retry: null,
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
    final argument = this.argument as (String, String);
    return registerBadge(ref, argument.$1, argument.$2);
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

String _$registerBadgeHash() => r'76dbd6c08c461f7ebbb99ee796518bb070d25f95';

final class RegisterBadgeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Badge>, (String, String)> {
  RegisterBadgeFamily._()
    : super(
        retry: null,
        name: r'registerBadgeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RegisterBadgeProvider call(String badgeId, String groupId) =>
      RegisterBadgeProvider._(argument: (badgeId, groupId), from: this);

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
    required (String, String) super.argument,
  }) : super(
         retry: null,
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
    final argument = this.argument as (String, String);
    return scanRegisterBadge(ref, argument.$1, argument.$2);
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

String _$scanRegisterBadgeHash() => r'2d69ad079620acee51fe77a950d835ae26e3ee58';

final class ScanRegisterBadgeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Group>, (String, String)> {
  ScanRegisterBadgeFamily._()
    : super(
        retry: null,
        name: r'scanRegisterBadgeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ScanRegisterBadgeProvider call(String qrPayload, String groupName) =>
      ScanRegisterBadgeProvider._(argument: (qrPayload, groupName), from: this);

  @override
  String toString() => r'scanRegisterBadgeProvider';
}
