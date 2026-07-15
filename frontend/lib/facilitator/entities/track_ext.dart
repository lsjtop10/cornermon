import 'package:cornermon/shared/api/domain_aliases.dart';

extension FacilitatorTrackX on Track {
  bool get isIdle => operationalStatus == TrackOperationalStatus.IDLE;
  bool get isBusy => operationalStatus == TrackOperationalStatus.BUSY;
  bool get isActive => status == TrackStatus.ACTIVE;
  bool get isDeleted => status == TrackStatus.DELETED;
}
