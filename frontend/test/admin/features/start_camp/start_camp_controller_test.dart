import 'package:cornermon/admin/features/start_camp/start_camp_controller.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/camp_providers.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ShoudReplaceSelectedCampSnapshotWhenStartSucceeds', () async {
    // arrange
    final campId = CampId('camp-1');
    final activeCamp = CampResponse(
      (b) => b
        ..id = campId.value
        ..status = CampResponseStatusEnum.ACTIVE,
    );
    final container = ProviderContainer(
      overrides: [
        startCampProvider(campId).overrideWith((_) async => activeCamp),
      ],
    );
    addTearDown(container.dispose);
    container.read(selectedCampIdProvider.notifier).select(campId);

    // act
    await container.read(startCampControllerProvider.notifier).confirm();

    // assert
    expect(container.read(selectedCampSnapshotProvider), activeCamp);
    expect(await container.read(selectedCampProvider.future), activeCamp);
    expect(container.read(startCampControllerProvider).hasError, isFalse);
  });
}
