import 'package:cornermon/admin/features/settings/update_camp_controller.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/camp_providers.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ShoudReplaceSelectedCampSnapshotWhenSaveSucceeds', () async {
    // arrange
    final campId = CampId('camp-1');
    final updatedCamp = CampResponse(
      (b) => b
        ..id = campId.value
        ..name = '새 이름'
        ..bottleneckMinSamples = 5
        ..bottleneckRatioPct = 30
        ..status = CampResponseStatusEnum.ACTIVE,
    );
    final container = ProviderContainer(
      overrides: [
        updateCampProvider(
          campId,
          name: '새 이름',
          bottleneckMinSamples: 5,
          bottleneckRatioPct: 30,
        ).overrideWith((_) async => updatedCamp),
      ],
    );
    addTearDown(container.dispose);

    // act
    await container
        .read(updateCampControllerProvider.notifier)
        .save(
          campId,
          name: '새 이름',
          bottleneckMinSamples: 5,
          bottleneckRatioPct: 30,
        );

    // assert
    expect(container.read(selectedCampSnapshotProvider), updatedCamp);
    expect(container.read(updateCampControllerProvider).hasError, isFalse);
  });

  test('ShoudRethrowAndNotReplaceSnapshotWhenSaveFails', () async {
    // arrange
    final campId = CampId('camp-1');
    final container = ProviderContainer(
      overrides: [
        updateCampProvider(
          campId,
          bottleneckMinSamples: -1,
          bottleneckRatioPct: 20,
        ).overrideWith((_) async => throw Exception('0 이하 값은 저장할 수 없습니다')),
      ],
    );
    addTearDown(container.dispose);

    // act & assert
    await expectLater(
      () => container
          .read(updateCampControllerProvider.notifier)
          .save(campId, bottleneckMinSamples: -1, bottleneckRatioPct: 20),
      throwsA(isA<Exception>()),
    );
    expect(container.read(selectedCampSnapshotProvider), isNull);
    expect(container.read(updateCampControllerProvider).hasError, isTrue);
  });
}
