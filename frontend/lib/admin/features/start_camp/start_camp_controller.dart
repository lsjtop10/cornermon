import 'dart:async';

import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/providers/camp_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final startCampControllerProvider =
    AsyncNotifierProvider<StartCampController, void>(StartCampController.new);

class StartCampController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> confirm() async {
    final campId = ref.read(selectedCampIdProvider);
    if (campId == null) return;
    state = const AsyncLoading();
    final subscription = ref.listen(startCampProvider(campId), (_, _) {});
    try {
      final camp = await ref.read(startCampProvider(campId).future);
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
