import 'package:cornermon_api_gen/cornermon_api_gen.dart' as api;

extension AdminCampX on api.Camp {
  bool get isPending => status == api.CampStatus.PENDING;
  bool get isActive => status == api.CampStatus.ACTIVE;
  bool get isEnded => status == api.CampStatus.ENDED;
}
