import 'dart:async';

import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/providers/camp_providers.dart';
import 'package:cornermon/shared/api/providers/report_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final endCampControllerProvider =
    AsyncNotifierProvider<EndCampController, void>(EndCampController.new);

class EndCampController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// 직전 [confirm] 호출에서 리포트 자동 생성(`generateReport`)이 실패했는지
  /// 여부. `endCamp` 자체의 성공/실패와는 별개다 — 호출부(다이얼로그)가 pop 후
  /// 캠프 목록으로 이동하고 나서 경고 스낵바를 띄울지 판단하는 데 쓴다.
  bool lastReportGenerationFailed = false;

  Future<void> confirm() async {
    final campId = ref.read(selectedCampIdProvider);
    if (campId == null) return;
    state = const AsyncLoading();

    final endSubscription = ref.listen(endCampProvider(campId), (_, _) {});
    try {
      await ref.read(endCampProvider(campId).future);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      endSubscription.close();
    }

    // endCamp가 성공했을 때만 여기 도달한다. 리포트 자동 생성 실패는 코너학습
    // 종료 자체의 실패로 취급하지 않는다 — A12(리포트)에서 재생성 가능하므로
    // 실패 여부만 플래그로 남기고 무조건 다음 단계(캠프 선택 해제)로 진행한다.
    lastReportGenerationFailed = false;
    final reportSubscription = ref.listen(
      generateReportProvider(campId),
      (_, _) {},
    );
    try {
      await ref.read(generateReportProvider(campId).future);
    } catch (_) {
      lastReportGenerationFailed = true;
    } finally {
      reportSubscription.close();
    }

    ref.read(selectedCampIdProvider.notifier).clear();
  }
}
