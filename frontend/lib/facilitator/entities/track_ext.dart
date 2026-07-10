import 'package:cornermon_api_gen/cornermon_api_gen.dart' as api;

extension FacilitatorTrackX on api.Track {
  bool get isIdle => operationalStatus == api.TrackOperationalStatus.IDLE;
  bool get isBusy => operationalStatus == api.TrackOperationalStatus.BUSY;
  bool get isActive => status == api.TrackStatus.ACTIVE;
  bool get isDeleted => status == api.TrackStatus.DELETED;
}
