import '../../shared/api/domain_aliases.dart' as api;

extension AdminGroupX on api.Group {
  bool get isFinished {
    final Iterable<api.CornerProgress> itin = itinerary ?? const <api.CornerProgress>[];
    if (itin.isEmpty) return false;
    return itin.every((p) => p.status == api.VisitStatusPerCorner.COMPLETED);
  }

  int get completedCount {
    final Iterable<api.CornerProgress> itin = itinerary ?? const <api.CornerProgress>[];
    return itin.where((p) => p.status == api.VisitStatusPerCorner.COMPLETED).length;
  }

  String get completedCountLabel {
    final Iterable<api.CornerProgress> itin = itinerary ?? const <api.CornerProgress>[];
    final total = itin.length;
    return '$completedCount/$total';
  }
}
