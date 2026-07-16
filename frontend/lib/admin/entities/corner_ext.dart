import 'package:cornermon/shared/api/domain_aliases.dart' as api;

extension AdminCornerX on api.Corner {
  String get displayName =>
      name?.trim().isNotEmpty == true ? name! : '이름 없는 코너';
}
