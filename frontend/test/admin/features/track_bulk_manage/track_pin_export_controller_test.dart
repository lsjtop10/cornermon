import 'package:cornermon/admin/features/track_bulk_manage/track_pin_export_controller.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/export/export_file.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ShoudSaveWorkbookWithXlsxMetadataWhenExportAndSaveSucceeds', () async {
    // arrange
    final campId = CampId('camp-1');
    ExportFile? savedFile;
    final container = ProviderContainer(
      overrides: [
        exportAllTrackPinsProvider(campId).overrideWith(
          (_) async => ExportTracksResponse((b) => b..tracks.replace([])),
        ),
        saveExportFileProvider.overrideWithValue((file) async {
          savedFile = file;
          return ExportSaveResult.saved;
        }),
      ],
    );
    addTearDown(container.dispose);

    // act
    final result = await container
        .read(trackPinExportControllerProvider.notifier)
        .exportAndSave(campId);

    // assert
    expect(result, ExportSaveResult.saved);
    expect(savedFile!.filename, 'track-pins.xlsx');
    expect(savedFile!.mimeType.name, 'Microsoft Excel');
    expect(container.read(trackPinExportControllerProvider).hasError, isFalse);
  });

  test('ShoudNotSetErrorWhenWorkbookSaveIsCancelled', () async {
    // arrange
    final campId = CampId('camp-1');
    final container = ProviderContainer(
      overrides: [
        exportAllTrackPinsProvider(campId).overrideWith(
          (_) async => ExportTracksResponse((b) => b..tracks.replace([])),
        ),
        saveExportFileProvider.overrideWithValue(
          (_) async => ExportSaveResult.cancelled,
        ),
      ],
    );
    addTearDown(container.dispose);

    // act
    final result = await container
        .read(trackPinExportControllerProvider.notifier)
        .exportAndSave(campId);

    // assert
    expect(result, ExportSaveResult.cancelled);
    expect(container.read(trackPinExportControllerProvider).hasError, isFalse);
  });
}
