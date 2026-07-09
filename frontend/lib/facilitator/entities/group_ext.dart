import 'package:cornermon_api_gen/cornermon_api_gen.dart' as api;

extension FacilitatorGroupX on api.Group {
  String get nextCornerLabel {
    final itin = itinerary;
    if (itin.isEmpty) return '없음';

    for (final p in itin) {
      if (p.status == api.VisitStatusPerCorner.NOT_VISITED) {
        return p.cornerName ?? p.cornerId;
      }
    }
    return '완주 완료';
  }
}
