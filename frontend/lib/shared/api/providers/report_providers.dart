import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import '../client/api_client.dart';

part 'report_providers.g.dart';

@riverpod
FReportsAnalyticsApi reportApi(Ref ref) {
  final dio = ref.watch(apiClientProvider);
  return FReportsAnalyticsApi(dio, serializers);
}

@riverpod
Future<CampReport> currentReport(Ref ref) async {
  final apiInstance = ref.watch(reportApiProvider);
  final response = await apiInstance.reportsCurrentGet();
  final data = response.data;
  if (data == null) {
    throw Exception('Report not found');
  }
  return data;
}

@riverpod
Future<ReportsLiveSummaryGet200Response> liveSummary(Ref ref) async {
  final apiInstance = ref.watch(reportApiProvider);
  final response = await apiInstance.reportsLiveSummaryGet();
  final data = response.data;
  if (data == null) {
    throw Exception('Live summary not found');
  }
  return data;
}
