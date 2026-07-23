import 'package:cornermon/admin/features/badge_precreate/badge_controllers.dart';
import 'package:cornermon/shared/api/providers/badge_providers.dart';
import 'package:cornermon/shared/export/export_file.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ShoudGenerateBadgesWhenQuantityIsValid', () async {
    // arrange
    var calls = 0;
    final container = ProviderContainer(
      overrides: [
        bulkGenerateBadgesProvider(3).overrideWith((_) async {
          calls++;
          return <BadgeResponse>[];
        }),
      ],
    );
    addTearDown(container.dispose);

    // act
    await container.read(badgeGenerateControllerProvider.notifier).generate(3);

    // assert
    expect(calls, 1);
    expect(container.read(badgeGenerateControllerProvider).hasError, isFalse);
  });

  test('ShoudNotSharePdfWhenExportedBadgeListIsEmpty', () async {
    // arrange
    var shareCalls = 0;
    final container = ProviderContainer(
      overrides: [
        exportUnassignedBadgesProvider.overrideWith((_) async => const []),
        badgePdfShareProvider.overrideWithValue(({
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
    final shared = await container
        .read(badgeExportControllerProvider.notifier)
        .exportAndShare();

    // assert
    expect(shared, isFalse);
    expect(shareCalls, 0);
  });

  test('ShoudSharePdfWhenUnassignedBadgesAreExported', () async {
    // arrange
    var shareCalls = 0;
    String? sharedFilename;
    final container = ProviderContainer(
      overrides: [
        exportUnassignedBadgesProvider.overrideWith(
          (_) async => [
            BadgeResponse(
              (b) => b
                ..id = 'badge-1'
                ..shortId = 'B-0001'
                ..qrPayload = 'payload',
            ),
          ],
        ),
        badgePdfShareProvider.overrideWithValue(({
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
    final shared = await container
        .read(badgeExportControllerProvider.notifier)
        .exportAndShare();

    // assert
    expect(shared, isTrue);
    expect(shareCalls, 1);
    expect(sharedFilename, startsWith('cornermon-badges-'));
  });

  test('ShoudNotSetErrorWhenBadgePdfSaveIsCancelled', () async {
    // arrange
    final container = ProviderContainer(
      overrides: [
        exportUnassignedBadgesProvider.overrideWith(
          (_) async => [
            BadgeResponse(
              (b) => b
                ..id = 'badge-1'
                ..shortId = 'B-0001'
                ..qrPayload = 'payload',
            ),
          ],
        ),
        saveExportFileProvider.overrideWithValue(
          (_) async => ExportSaveResult.cancelled,
        ),
      ],
    );
    addTearDown(container.dispose);

    // act
    final result = await container
        .read(badgeExportControllerProvider.notifier)
        .exportAndSave();

    // assert
    expect(result, ExportSaveResult.cancelled);
    expect(container.read(badgeExportControllerProvider).hasError, isFalse);
  });
}
