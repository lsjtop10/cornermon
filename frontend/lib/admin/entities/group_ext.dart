import 'package:cornermon_api_gen/cornermon_api_gen.dart' as api;

extension AdminGroupX on api.Group {
  bool get isFinished {
    final itin = itinerary;
    if (itin.isEmpty) return false;
    return itin.every((p) => p.status == api.VisitStatusPerCorner.COMPLETED);
  }

  int get completedCount {
    final itin = itinerary;
    return itin.where((p) => p.status == api.VisitStatusPerCorner.COMPLETED).length;
  }

  String get completedCountLabel {
    final itin = itinerary;
    final total = itin.length;
    return '$completedCount/$total';
  }
}
