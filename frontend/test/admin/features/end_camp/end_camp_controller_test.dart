import 'package:cornermon/admin/features/end_camp/end_camp_controller.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/camp_providers.dart';
import 'package:cornermon/shared/api/providers/report_providers.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final campId = CampId('camp-1');

  CampResponse endedCamp() => CampResponse(
    (b) => b
      ..id = campId.value
      ..status = CampResponseStatusEnum.ENDED,
  );

  CampReportResponse report() =>
      CampReportResponse((b) => b..campId = campId.value);

  test('ShoudClearSelectedCampIdWhenEndAndReportBothSucceed', () async {
    // arrange
    final container = ProviderContainer(
      overrides: [
        endCampProvider(campId).overrideWith((_) async => endedCamp()),
        generateReportProvider(campId).overrideWith((_) async => report()),
      ],
    );
    addTearDown(container.dispose);
    container.read(selectedCampIdProvider.notifier).select(campId);

    // act
    await container.read(endCampControllerProvider.notifier).confirm();

    // assert
    expect(container.read(selectedCampIdProvider), isNull);
    expect(container.read(endCampControllerProvider).hasError, isFalse);
    expect(
      container
          .read(endCampControllerProvider.notifier)
          .lastReportGenerationFailed,
      isFalse,
    );
  });

  test(
    'ShoudSetReportGenerationFailedFlagAndStillClearSelectedCampIdWhenReportGenerationFails',
    () async {
      // arrange
      final container = ProviderContainer(
        overrides: [
          endCampProvider(campId).overrideWith((_) async => endedCamp()),
          generateReportProvider(
            campId,
          ).overrideWith((_) async => throw Exception('리포트 생성 실패')),
        ],
      );
      addTearDown(container.dispose);
      container.read(selectedCampIdProvider.notifier).select(campId);

      // act
      await container.read(endCampControllerProvider.notifier).confirm();

      // assert
      expect(container.read(selectedCampIdProvider), isNull);
      expect(container.read(endCampControllerProvider).hasError, isFalse);
      expect(
        container
            .read(endCampControllerProvider.notifier)
            .lastReportGenerationFailed,
        isTrue,
      );
    },
  );

  test('ShoudThrowAndKeepSelectedCampIdWhenEndCampFails', () async {
    // arrange
    var generateReportCalls = 0;
    final container = ProviderContainer(
      overrides: [
        endCampProvider(
          campId,
        ).overrideWith((_) async => throw Exception('종료 조건 미충족')),
        generateReportProvider(campId).overrideWith((_) async {
          generateReportCalls++;
          return report();
        }),
      ],
    );
    addTearDown(container.dispose);
    container.read(selectedCampIdProvider.notifier).select(campId);

    // act
    Object? caught;
    try {
      await container.read(endCampControllerProvider.notifier).confirm();
    } catch (error) {
      caught = error;
    }

    // assert
    expect(caught, isNotNull);
    expect(generateReportCalls, 0);
    expect(container.read(selectedCampIdProvider), campId);
    expect(container.read(endCampControllerProvider).hasError, isTrue);
  });

  test('ShoudCallEndCampBeforeGenerateReport', () async {
    // arrange
    final callOrder = <String>[];
    final container = ProviderContainer(
      overrides: [
        endCampProvider(campId).overrideWith((_) async {
          callOrder.add('end');
          return endedCamp();
        }),
        generateReportProvider(campId).overrideWith((_) async {
          callOrder.add('generateReport');
          return report();
        }),
      ],
    );
    addTearDown(container.dispose);
    container.read(selectedCampIdProvider.notifier).select(campId);

    // act
    await container.read(endCampControllerProvider.notifier).confirm();

    // assert
    expect(callOrder, ['end', 'generateReport']);
  });
}
