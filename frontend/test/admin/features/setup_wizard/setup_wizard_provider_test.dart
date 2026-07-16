import 'package:cornermon/admin/features/setup_wizard/setup_wizard_provider.dart';
import 'package:cornermon/admin/features/setup_wizard/setup_wizard_state.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/camp_providers.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SetupWizard', () {
    test('parses non-empty lines using current defaults', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(setupWizardProvider.notifier);

      notifier.setDefaults(targetMinutes: 15, trackCountPerCorner: 2);
      notifier.parseCornerNames(
        List.generate(10, (index) => '코너 ${index + 1}').join('\n'),
      );

      final state = container.read(setupWizardProvider);
      expect(state.corners, hasLength(10));
      expect(
        state.corners.every(
          (row) => row.targetMinutes == 15 && row.trackCount == 2,
        ),
        isTrue,
      );
    });

    test(
      'allows advancing without a corner and changes only the requested row',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(setupWizardProvider.notifier);

        expect(notifier.tryAdvanceFromCornerStep(), isTrue);
        expect(container.read(setupWizardProvider).step, 2);

        notifier.parseCornerNames('1코너\n2코너');
        notifier.updateCornerRow(1, targetMinutes: 20, trackCount: 3);
        final rows = container.read(setupWizardProvider).corners;
        expect(rows[0].targetMinutes, 10);
        expect(rows[1].targetMinutes, 20);
        expect(rows[1].trackCount, 3);
        expect(rows[0].status, SetupWizardCornerStatus.pending);
        notifier.removeCornerRow(0);
        expect(
          container.read(setupWizardProvider).corners.map((row) => row.name),
          ['2코너'],
        );
      },
    );

    test('creates camp, corners, and tracks in sequence', () async {
      final calls = <String>[];
      final start = DateTime(2026, 7, 20);
      final end = DateTime(2026, 7, 21);
      final campId = CampId('camp-1');
      final container = ProviderContainer(
        overrides: [
          createCampProvider(
            '여름 캠프',
            startAt: start,
            endAt: end,
          ).overrideWith((ref) async {
            calls.add('camp');
            return CampResponse((b) => b..id = campId.value);
          }),
          createCornerProvider(campId, '1코너', 10).overrideWith((ref) async {
            calls.add('corner:1');
            return CornerResponse((b) => b..id = 'corner-1');
          }),
          createCornerProvider(campId, '2코너', 10).overrideWith((ref) async {
            calls.add('corner:2');
            return CornerResponse((b) => b..id = 'corner-2');
          }),
          createTracksForCornerProvider(
            campId,
            CornerId('corner-1'),
            1,
          ).overrideWith((ref) async {
            calls.add('tracks:1');
            return <TrackPinResponse>[];
          }),
          createTracksForCornerProvider(
            campId,
            CornerId('corner-2'),
            1,
          ).overrideWith((ref) async {
            calls.add('tracks:2');
            return <TrackPinResponse>[];
          }),
        ],
      );
      addTearDown(container.dispose);
      final wizard = container.read(setupWizardProvider.notifier);
      wizard.setCampInfo('여름 캠프', start, end);
      wizard.parseCornerNames('1코너\n2코너');

      expect(await wizard.submit(), isTrue);
      expect(calls, [
        'camp',
        'corner:1',
        'tracks:1',
        'corner:2',
        'tracks:2',
      ]);
      expect(container.read(selectedCampIdProvider), campId);
    });

    test('creates a camp successfully without corners', () async {
      final campId = CampId('camp-only');
      final start = DateTime(2026, 7, 20);
      final end = DateTime(2026, 7, 21);
      final container = ProviderContainer(
        overrides: [
          createCampProvider(
            '빈 캠프',
            startAt: start,
            endAt: end,
          ).overrideWith(
            (ref) async => CampResponse((b) => b..id = campId.value),
          ),
        ],
      );
      addTearDown(container.dispose);
      final wizard = container.read(setupWizardProvider.notifier);
      wizard.setCampInfo('빈 캠프', start, end);

      expect(await wizard.submit(), isTrue);
      expect(container.read(selectedCampIdProvider), campId);
    });

    test(
      'keeps a failed row retryable without recreating successful rows',
      () async {
        var secondCornerAttempts = 0;
        var firstCornerAttempts = 0;
        final campId = CampId('camp-1');
        final start = DateTime(2026, 7, 20);
        final end = DateTime(2026, 7, 21);
        final container = ProviderContainer(
          overrides: [
            createCampProvider(
              '캠프',
              startAt: start,
              endAt: end,
            ).overrideWith(
              (ref) async => CampResponse((b) => b..id = campId.value),
            ),
            createCornerProvider(campId, '1코너', 10).overrideWith((ref) async {
              firstCornerAttempts++;
              return CornerResponse((b) => b..id = 'corner-1');
            }),
            createCornerProvider(campId, '2코너', 10).overrideWith((ref) async {
              secondCornerAttempts++;
              if (secondCornerAttempts == 1) throw StateError('network');
              return CornerResponse((b) => b..id = 'corner-2');
            }),
            createTracksForCornerProvider(
              campId,
              CornerId('corner-1'),
              1,
            ).overrideWith((ref) async => <TrackPinResponse>[]),
            createTracksForCornerProvider(
              campId,
              CornerId('corner-2'),
              1,
            ).overrideWith((ref) async => <TrackPinResponse>[]),
          ],
        );
        addTearDown(container.dispose);
        final wizard = container.read(setupWizardProvider.notifier);
        wizard.setCampInfo('캠프', start, end);
        wizard.parseCornerNames('1코너\n2코너');

        expect(await wizard.submit(), isFalse);
        expect(
          container.read(setupWizardProvider).corners[1].status,
          SetupWizardCornerStatus.failed,
        );
        expect(await wizard.submit(), isTrue);
        expect(firstCornerAttempts, 1);
        expect(secondCornerAttempts, 2);
      },
    );
  });
}
