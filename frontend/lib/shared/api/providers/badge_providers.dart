import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'camp_providers.dart';

part 'badge_providers.g.dart';

@riverpod
Future<List<Badge>> badgeList(
  Ref ref, {
  BadgeStatus? status,
  String? search,
}) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.badgesGet(status: status, search: search);
  return response.data?.badges?.toList() ?? [];
}
