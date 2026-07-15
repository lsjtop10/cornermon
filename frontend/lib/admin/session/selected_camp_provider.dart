import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/camp_providers.dart';

final selectedCampIdProvider = NotifierProvider<SelectedCampId, CampId?>(
  SelectedCampId.new,
);

class SelectedCampId extends Notifier<CampId?> {
  @override
  CampId? build() => null;

  void select(CampId id) {
    ref.invalidate(selectedCampSnapshotProvider);
    state = id;
  }

  void clear() {
    ref.invalidate(selectedCampSnapshotProvider);
    state = null;
  }
}

/// A0-e의 startCamp 응답으로 재조회 없이 상태 전환을 반영하는 로컬 스냅샷이다.
final selectedCampSnapshotProvider =
    NotifierProvider<SelectedCampSnapshot, Camp?>(SelectedCampSnapshot.new);

class SelectedCampSnapshot extends Notifier<Camp?> {
  @override
  Camp? build() => null;

  void replace(Camp camp) => state = camp;
}

final selectedCampProvider = FutureProvider<Camp?>((ref) async {
  final id = ref.watch(selectedCampIdProvider);
  if (id == null) return null;
  final snapshot = ref.watch(selectedCampSnapshotProvider);
  if (snapshot?.id == id.value) return snapshot;
  return ref.watch(campDetailProvider(id).future);
});
