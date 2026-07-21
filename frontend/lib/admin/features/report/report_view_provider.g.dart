// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_view_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ACTIVE/PENDING 캠프(진행 중)는 `currentReport` 호출 자체를 시도하지 않고 곧장
/// [ReportViewNotGenerated]를 반환한다 — 캠프 status는 [selectedCampProvider]에서 이미
/// 알고 있으므로 "404를 기다렸다 판단"하지 않는다(§screen-spec "코너학습 진행 중(리포트
/// 미생성)" 문구와 정확히 대응, analytics-model.md §2 "캠프 종료 시점에만 배치 계산").
/// ENDED 캠프인 경우에만 `currentReport(campId)`를 호출하며, 실패(404 등 어떤 예외든)해도
/// [ReportViewNotGenerated]로 방어적으로 폴백한다 — API 계약에 미생성 시 응답이 명시돼
/// 있지 않기 때문(§0.1, PR #120으로 해소된 overDeviationRatio 갭과는 별개 사항).

@ProviderFor(reportView)
final reportViewProvider = ReportViewFamily._();

/// ACTIVE/PENDING 캠프(진행 중)는 `currentReport` 호출 자체를 시도하지 않고 곧장
/// [ReportViewNotGenerated]를 반환한다 — 캠프 status는 [selectedCampProvider]에서 이미
/// 알고 있으므로 "404를 기다렸다 판단"하지 않는다(§screen-spec "코너학습 진행 중(리포트
/// 미생성)" 문구와 정확히 대응, analytics-model.md §2 "캠프 종료 시점에만 배치 계산").
/// ENDED 캠프인 경우에만 `currentReport(campId)`를 호출하며, 실패(404 등 어떤 예외든)해도
/// [ReportViewNotGenerated]로 방어적으로 폴백한다 — API 계약에 미생성 시 응답이 명시돼
/// 있지 않기 때문(§0.1, PR #120으로 해소된 overDeviationRatio 갭과는 별개 사항).

final class ReportViewProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReportViewState>,
          ReportViewState,
          FutureOr<ReportViewState>
        >
    with $FutureModifier<ReportViewState>, $FutureProvider<ReportViewState> {
  /// ACTIVE/PENDING 캠프(진행 중)는 `currentReport` 호출 자체를 시도하지 않고 곧장
  /// [ReportViewNotGenerated]를 반환한다 — 캠프 status는 [selectedCampProvider]에서 이미
  /// 알고 있으므로 "404를 기다렸다 판단"하지 않는다(§screen-spec "코너학습 진행 중(리포트
  /// 미생성)" 문구와 정확히 대응, analytics-model.md §2 "캠프 종료 시점에만 배치 계산").
  /// ENDED 캠프인 경우에만 `currentReport(campId)`를 호출하며, 실패(404 등 어떤 예외든)해도
  /// [ReportViewNotGenerated]로 방어적으로 폴백한다 — API 계약에 미생성 시 응답이 명시돼
  /// 있지 않기 때문(§0.1, PR #120으로 해소된 overDeviationRatio 갭과는 별개 사항).
  ReportViewProvider._({
    required ReportViewFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: null,
         name: r'reportViewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reportViewHash();

  @override
  String toString() {
    return r'reportViewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ReportViewState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReportViewState> create(Ref ref) {
    final argument = this.argument as CampId;
    return reportView(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReportViewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reportViewHash() => r'38bb8973ee65c490190facd5dedb2b8f368c1ff4';

/// ACTIVE/PENDING 캠프(진행 중)는 `currentReport` 호출 자체를 시도하지 않고 곧장
/// [ReportViewNotGenerated]를 반환한다 — 캠프 status는 [selectedCampProvider]에서 이미
/// 알고 있으므로 "404를 기다렸다 판단"하지 않는다(§screen-spec "코너학습 진행 중(리포트
/// 미생성)" 문구와 정확히 대응, analytics-model.md §2 "캠프 종료 시점에만 배치 계산").
/// ENDED 캠프인 경우에만 `currentReport(campId)`를 호출하며, 실패(404 등 어떤 예외든)해도
/// [ReportViewNotGenerated]로 방어적으로 폴백한다 — API 계약에 미생성 시 응답이 명시돼
/// 있지 않기 때문(§0.1, PR #120으로 해소된 overDeviationRatio 갭과는 별개 사항).

final class ReportViewFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ReportViewState>, CampId> {
  ReportViewFamily._()
    : super(
        retry: null,
        name: r'reportViewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// ACTIVE/PENDING 캠프(진행 중)는 `currentReport` 호출 자체를 시도하지 않고 곧장
  /// [ReportViewNotGenerated]를 반환한다 — 캠프 status는 [selectedCampProvider]에서 이미
  /// 알고 있으므로 "404를 기다렸다 판단"하지 않는다(§screen-spec "코너학습 진행 중(리포트
  /// 미생성)" 문구와 정확히 대응, analytics-model.md §2 "캠프 종료 시점에만 배치 계산").
  /// ENDED 캠프인 경우에만 `currentReport(campId)`를 호출하며, 실패(404 등 어떤 예외든)해도
  /// [ReportViewNotGenerated]로 방어적으로 폴백한다 — API 계약에 미생성 시 응답이 명시돼
  /// 있지 않기 때문(§0.1, PR #120으로 해소된 overDeviationRatio 갭과는 별개 사항).

  ReportViewProvider call(CampId campId) =>
      ReportViewProvider._(argument: campId, from: this);

  @override
  String toString() => r'reportViewProvider';
}
