import 'package:cornermon/shared/api/domain_aliases.dart' as api;

extension AdminTrackX on api.Track {
  bool get isActive => status == api.TrackStatus.ACTIVE;
  bool get isBusy => operationalStatus == api.TrackOperationalStatus.BUSY;
  String get maskedPin => '••••••';
}

extension AdminTrackListX on Iterable<api.Track> {
  List<api.Track> activeForCorner(String cornerId) =>
      where((track) => track.cornerId == cornerId && track.isActive).toList();
}
