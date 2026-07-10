// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(badgeList)
final badgeListProvider = BadgeListFamily._();

final class BadgeListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Badge>>,
          List<Badge>,
          FutureOr<List<Badge>>
        >
    with $FutureModifier<List<Badge>>, $FutureProvider<List<Badge>> {
  BadgeListProvider._({
    required BadgeListFamily super.from,
    required ({BadgeStatus? status, String? search}) super.argument,
  }) : super(
         retry: null,
         name: r'badgeListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$badgeListHash();

  @override
  String toString() {
    return r'badgeListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Badge>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Badge>> create(Ref ref) {
    final argument = this.argument as ({BadgeStatus? status, String? search});
    return badgeList(ref, status: argument.status, search: argument.search);
  }

  @override
  bool operator ==(Object other) {
    return other is BadgeListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$badgeListHash() => r'61d86f8b22d3ed30ad35d6342d0368de187823a4';

final class BadgeListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Badge>>,
          ({BadgeStatus? status, String? search})
        > {
  BadgeListFamily._()
    : super(
        retry: null,
        name: r'badgeListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BadgeListProvider call({BadgeStatus? status, String? search}) =>
      BadgeListProvider._(
        argument: (status: status, search: search),
        from: this,
      );

  @override
  String toString() => r'badgeListProvider';
}
