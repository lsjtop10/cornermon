import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import '../client/api_client.dart';
import '../domain_aliases.dart';
import '../ids.dart';

part 'report_providers.g.dart';

@riverpod
DReportApi reportApi(Ref ref) {
  final dio = ref.watch(apiClientProvider);
  return DReportApi(dio, serializers);
}

@riverpod
Future<CampReport> currentReport(Ref ref, CampId campId) async {
  final apiInstance = ref.watch(reportApiProvider);
  final response = await apiInstance.campsCampIdReportsCurrentGet(campId: campId.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Report not found');
  }
  return data;
}

@riverpod
Future<CampReport> generateReport(Ref ref, CampId campId) async {
  final apiInstance = ref.watch(reportApiProvider);
  final response = await apiInstance.campsCampIdReportsGeneratePost(campId: campId.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Report generation response was empty');
  }
  return data;
}

@riverpod
Future<CampSummaryStats> liveSummary(Ref ref, CampId campId) async {
  final apiInstance = ref.watch(reportApiProvider);
  final response = await apiInstance.campsCampIdReportsLiveSummaryGet(campId: campId.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Live summary not found');
  }
  return data;
}

@riverpod
Future<CampReport> exportReport(Ref ref, CampId campId) async {
  final apiInstance = ref.watch(reportApiProvider);
  final response = await apiInstance.campsCampIdReportsCurrentExportGet(campId: campId.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Report export response was empty');
  }
  return data;
}
