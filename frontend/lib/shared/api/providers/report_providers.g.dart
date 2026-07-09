// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportApiHash() => r'40f666cfbc3210748cd035fa9a87c507c253fbf7';

/// See also [reportApi].
@ProviderFor(reportApi)
final reportApiProvider = AutoDisposeProvider<FReportsAnalyticsApi>.internal(
  reportApi,
  name: r'reportApiProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReportApiRef = AutoDisposeProviderRef<FReportsAnalyticsApi>;
String _$currentReportHash() => r'0e4edfb8237fa7bcf4730e49213ffdafb949ade3';

/// See also [currentReport].
@ProviderFor(currentReport)
final currentReportProvider = AutoDisposeFutureProvider<CampReport>.internal(
  currentReport,
  name: r'currentReportProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentReportHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentReportRef = AutoDisposeFutureProviderRef<CampReport>;
String _$liveSummaryHash() => r'4bdc3438f64da5e839f07d847dbe108d77793278';

/// See also [liveSummary].
@ProviderFor(liveSummary)
final liveSummaryProvider =
    AutoDisposeFutureProvider<ReportsLiveSummaryGet200Response>.internal(
      liveSummary,
      name: r'liveSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$liveSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LiveSummaryRef =
    AutoDisposeFutureProviderRef<ReportsLiveSummaryGet200Response>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
