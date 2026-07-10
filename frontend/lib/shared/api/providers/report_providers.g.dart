// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reportApi)
final reportApiProvider = ReportApiProvider._();

final class ReportApiProvider
    extends
        $FunctionalProvider<
          FReportsAnalyticsApi,
          FReportsAnalyticsApi,
          FReportsAnalyticsApi
        >
    with $Provider<FReportsAnalyticsApi> {
  ReportApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportApiHash();

  @$internal
  @override
  $ProviderElement<FReportsAnalyticsApi> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FReportsAnalyticsApi create(Ref ref) {
    return reportApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FReportsAnalyticsApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FReportsAnalyticsApi>(value),
    );
  }
}

String _$reportApiHash() => r'b17fbb50b4d085c472eea1649357b0ffa2ec2ec1';

@ProviderFor(currentReport)
final currentReportProvider = CurrentReportProvider._();

final class CurrentReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<CampReport>,
          CampReport,
          FutureOr<CampReport>
        >
    with $FutureModifier<CampReport>, $FutureProvider<CampReport> {
  CurrentReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentReportHash();

  @$internal
  @override
  $FutureProviderElement<CampReport> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CampReport> create(Ref ref) {
    return currentReport(ref);
  }
}

String _$currentReportHash() => r'4199b44103de722c1a0216162ecf82dd1058e435';

@ProviderFor(liveSummary)
final liveSummaryProvider = LiveSummaryProvider._();

final class LiveSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReportsLiveSummaryGet200Response>,
          ReportsLiveSummaryGet200Response,
          FutureOr<ReportsLiveSummaryGet200Response>
        >
    with
        $FutureModifier<ReportsLiveSummaryGet200Response>,
        $FutureProvider<ReportsLiveSummaryGet200Response> {
  LiveSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveSummaryHash();

  @$internal
  @override
  $FutureProviderElement<ReportsLiveSummaryGet200Response> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReportsLiveSummaryGet200Response> create(Ref ref) {
    return liveSummary(ref);
  }
}

String _$liveSummaryHash() => r'03e4bc0630091a3d80862975c98faf784ee6204a';
