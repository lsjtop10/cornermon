import 'dart:async';

import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/camp_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A15 설정의 두 섹션(캠프 정보, 병목 판정 기준)이 공유하는 저장 액션 컨트롤러.
///
/// `frontend/docs/DEVELOPER_GUIDE.md` §2.2 패턴을 따른다 — `updateCamp`처럼
/// `ref.read(provider.future)`로 1회성 소비하는 액션 provider는 `ref.listen`을
/// 직전에 걸어야 provider가 에러로 끝날 때 의미 없는 내부 오류
/// (`disposed during loading state`) 대신 실제 예외가 올라온다. `ConsumerState`의
/// `WidgetRef.listen`은 `build` 중에만 호출 가능하고 반환형도 `void`라 이 패턴에
/// 쓸 수 없으므로, `StartCampController`와 동일하게 `AsyncNotifier`(`Ref`) 안에서
/// 수행한다.
///
/// 저장 성공 시 `selectedCampSnapshotProvider`에 응답을 직접 반영해 재조회 없이
/// 즉시 최신 캠프 상태를 캐시에 채운다(`start_camp_controller.dart`와 동일 패턴).
final updateCampControllerProvider =
    AsyncNotifierProvider<UpdateCampController, void>(
      UpdateCampController.new,
    );

class UpdateCampController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> save(
    CampId id, {
    String? name,
    DateTime? startAt,
    DateTime? endAt,
    int? bottleneckMinSamples,
    int? bottleneckRatioPct,
  }) async {
    state = const AsyncLoading();
    final provider = updateCampProvider(
      id,
      name: name,
      startAt: startAt,
      endAt: endAt,
      bottleneckMinSamples: bottleneckMinSamples,
      bottleneckRatioPct: bottleneckRatioPct,
    );
    final subscription = ref.listen(provider, (_, _) {});
    try {
      final camp = await ref.read(provider.future);
      ref.read(selectedCampSnapshotProvider.notifier).replace(camp);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      subscription.close();
    }
  }
}
