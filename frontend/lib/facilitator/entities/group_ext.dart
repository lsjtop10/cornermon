import 'package:cornermon/shared/api/domain_aliases.dart';

extension FacilitatorGroupX on Group {
  String get nextCornerLabel {
    final itin = itinerary ?? const <CornerProgress>[];
    if (itin.isEmpty) return '없음';

    for (final p in itin) {
      if (p.status == VisitStatusPerCorner.NOT_VISITED) {
        return p.cornerName ?? p.cornerId ?? '알 수 없음';
      }
    }
    return '완주 완료';
  }
}
