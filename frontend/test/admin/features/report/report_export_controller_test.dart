import 'package:cornermon/admin/features/report/report_export_controller.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/report_providers.dart';
import 'package:cornermon/shared/export/export_file.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

CampReportResponse _report() => CampReportResponse((b) => b..campId = 'camp-1');

void main() {
  test('ShoudSharePdfWhenExportAndShareSucceeds', () async {
    // arrange
    final campId = CampId('camp-1');
    var shareCalls = 0;
    String? sharedFilename;
    final container = ProviderContainer(
      overrides: [
        exportReportProvider(campId).overrideWith((ref) async => _report()),
        reportPdfShareProvider.overrideWithValue(({
          required bytes,
          required filename,
        }) async {
          shareCalls++;
          sharedFilename = filename;
          return true;
        }),
      ],
    );
    addTearDown(container.dispose);

    // act
    await container
        .read(reportExportControllerProvider.notifier)
        .exportAndShare(campId);

    // assert
    expect(shareCalls, 1);
    expect(sharedFilename, startsWith('cornermon-report-camp-1-'));
    expect(container.read(reportExportControllerProvider).hasError, isFalse);
  });

  test('ShoudNotSharePdfWhenExportReportFails', () async {
    // arrange
    final campId = CampId('camp-1');
    var shareCalls = 0;
    final container = ProviderContainer(
      overrides: [
        exportReportProvider(
          campId,
        ).overrideWith((ref) async => throw Exception('네트워크 오류')),
        reportPdfShareProvider.overrideWithValue(({
          required bytes,
          required filename,
        }) async {
          shareCalls++;
          return true;
        }),
      ],
    );
    addTearDown(container.dispose);

    // act
    await container
        .read(reportExportControllerProvider.notifier)
        .exportAndShare(campId);

    // assert
    expect(shareCalls, 0);
    expect(container.read(reportExportControllerProvider).hasError, isTrue);
  });

  test('ShoudSavePdfWithPdfMetadataWhenExportAndSaveSucceeds', () async {
    // arrange
    final campId = CampId('camp-1');
    ExportFile? savedFile;
    final container = ProviderContainer(
      overrides: [
        exportReportProvider(campId).overrideWith((ref) async => _report()),
        saveExportFileProvider.overrideWithValue((file) async {
          savedFile = file;
          return ExportSaveResult.saved;
        }),
      ],
    );
    addTearDown(container.dispose);

    // act
    final result = await container
        .read(reportExportControllerProvider.notifier)
        .exportAndSave(campId);

    // assert
    expect(result, ExportSaveResult.saved);
    expect(savedFile!.filename, startsWith('cornermon-report-camp-1-'));
    expect(savedFile!.fileExtension, 'pdf');
    expect(savedFile!.mimeType.name, 'PDF');
    expect(container.read(reportExportControllerProvider).hasError, isFalse);
  });

  test('ShoudNotSetErrorWhenSaveIsCancelled', () async {
    // arrange
    final campId = CampId('camp-1');
    final container = ProviderContainer(
      overrides: [
        exportReportProvider(campId).overrideWith((ref) async => _report()),
        saveExportFileProvider.overrideWithValue(
          (_) async => ExportSaveResult.cancelled,
        ),
      ],
    );
    addTearDown(container.dispose);

    // act
    final result = await container
        .read(reportExportControllerProvider.notifier)
        .exportAndSave(campId);

    // assert
    expect(result, ExportSaveResult.cancelled);
    expect(container.read(reportExportControllerProvider).hasError, isFalse);
  });
}
