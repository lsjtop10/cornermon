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
    extends $FunctionalProvider<DReportApi, DReportApi, DReportApi>
    with $Provider<DReportApi> {
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
  $ProviderElement<DReportApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DReportApi create(Ref ref) {
    return reportApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DReportApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DReportApi>(value),
    );
  }
}

String _$reportApiHash() => r'ead9e38b6b3b34d6aade67fdc949b468dce99248';

@ProviderFor(currentReport)
final currentReportProvider = CurrentReportFamily._();

final class CurrentReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<CampReport>,
          CampReport,
          FutureOr<CampReport>
        >
    with $FutureModifier<CampReport>, $FutureProvider<CampReport> {
  CurrentReportProvider._({
    required CurrentReportFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: null,
         name: r'currentReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$currentReportHash();

  @override
  String toString() {
    return r'currentReportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CampReport> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CampReport> create(Ref ref) {
    final argument = this.argument as CampId;
    return currentReport(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$currentReportHash() => r'794bfcd6de1e713024ad52645b45d24eda32c291';

final class CurrentReportFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CampReport>, CampId> {
  CurrentReportFamily._()
    : super(
        retry: null,
        name: r'currentReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CurrentReportProvider call(CampId campId) =>
      CurrentReportProvider._(argument: campId, from: this);

  @override
  String toString() => r'currentReportProvider';
}

@ProviderFor(generateReport)
final generateReportProvider = GenerateReportFamily._();

final class GenerateReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<CampReport>,
          CampReport,
          FutureOr<CampReport>
        >
    with $FutureModifier<CampReport>, $FutureProvider<CampReport> {
  GenerateReportProvider._({
    required GenerateReportFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: noRetry,
         name: r'generateReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$generateReportHash();

  @override
  String toString() {
    return r'generateReportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CampReport> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CampReport> create(Ref ref) {
    final argument = this.argument as CampId;
    return generateReport(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GenerateReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$generateReportHash() => r'07a49afe5c65e1f8c746abdb5a3fa975c9c01836';

final class GenerateReportFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CampReport>, CampId> {
  GenerateReportFamily._()
    : super(
        retry: noRetry,
        name: r'generateReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GenerateReportProvider call(CampId campId) =>
      GenerateReportProvider._(argument: campId, from: this);

  @override
  String toString() => r'generateReportProvider';
}

@ProviderFor(liveSummary)
final liveSummaryProvider = LiveSummaryFamily._();

final class LiveSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<CampSummaryStats>,
          CampSummaryStats,
          FutureOr<CampSummaryStats>
        >
    with $FutureModifier<CampSummaryStats>, $FutureProvider<CampSummaryStats> {
  LiveSummaryProvider._({
    required LiveSummaryFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: null,
         name: r'liveSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveSummaryHash();

  @override
  String toString() {
    return r'liveSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CampSummaryStats> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CampSummaryStats> create(Ref ref) {
    final argument = this.argument as CampId;
    return liveSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LiveSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveSummaryHash() => r'0862e00e13c3934580cf45dea195f47ff67111c2';

final class LiveSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CampSummaryStats>, CampId> {
  LiveSummaryFamily._()
    : super(
        retry: null,
        name: r'liveSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LiveSummaryProvider call(CampId campId) =>
      LiveSummaryProvider._(argument: campId, from: this);

  @override
  String toString() => r'liveSummaryProvider';
}

@ProviderFor(exportReport)
final exportReportProvider = ExportReportFamily._();

final class ExportReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<CampReport>,
          CampReport,
          FutureOr<CampReport>
        >
    with $FutureModifier<CampReport>, $FutureProvider<CampReport> {
  ExportReportProvider._({
    required ExportReportFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: null,
         name: r'exportReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exportReportHash();

  @override
  String toString() {
    return r'exportReportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CampReport> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CampReport> create(Ref ref) {
    final argument = this.argument as CampId;
    return exportReport(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExportReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exportReportHash() => r'1b9856f9a48cf957da62e0bcd2b70eac15170dae';

final class ExportReportFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CampReport>, CampId> {
  ExportReportFamily._()
    : super(
        retry: null,
        name: r'exportReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExportReportProvider call(CampId campId) =>
      ExportReportProvider._(argument: campId, from: this);

  @override
  String toString() => r'exportReportProvider';
}
