import '../../shared/api/domain_aliases.dart' as api;

extension AdminGroupX on api.Group {
  int get completedCount {
    final Iterable<api.CornerProgress> itin =
        itinerary ?? const <api.CornerProgress>[];
    return itin
        .where((p) => p.status == api.VisitStatusPerCorner.COMPLETED)
        .length;
  }

  String get completedCountLabel {
    final Iterable<api.CornerProgress> itin =
        itinerary ?? const <api.CornerProgress>[];
    final total = itin.length;
    return '$completedCount/$total';
  }

  double get completionRate {
    final total = (itinerary ?? const <api.CornerProgress>[]).length;
    return total == 0 ? 0 : completedCount / total;
  }
}
