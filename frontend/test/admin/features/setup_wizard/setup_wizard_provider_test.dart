import 'package:cornermon/admin/features/setup_wizard/setup_wizard_provider.dart';
import 'package:cornermon/admin/features/setup_wizard/setup_wizard_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SetupWizard', () {
    test('parses non-empty lines using current defaults', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(setupWizardProvider.notifier);

      notifier.setDefaults(targetMinutes: 15, trackCountPerCorner: 2);
      notifier.parseCornerNames('미술\n\n과학\n음악');

      final state = container.read(setupWizardProvider);
      expect(state.corners.map((row) => row.name), ['미술', '과학', '음악']);
      expect(
        state.corners.every(
          (row) => row.targetMinutes == 15 && row.trackCount == 2,
        ),
        isTrue,
      );
    });

    test(
      'blocks advance without a corner and changes only the requested row',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(setupWizardProvider.notifier);

        expect(notifier.tryAdvanceFromCornerStep(), isFalse);
        expect(
          container.read(setupWizardProvider).blockedMessage,
          '코너를 1개 이상 추가하세요',
        );

        notifier.parseCornerNames('1코너\n2코너');
        notifier.updateCornerRow(1, targetMinutes: 20, trackCount: 3);
        final rows = container.read(setupWizardProvider).corners;
        expect(rows[0].targetMinutes, 10);
        expect(rows[1].targetMinutes, 20);
        expect(rows[1].trackCount, 3);
        expect(rows[0].status, SetupWizardCornerStatus.pending);
      },
    );
  });
}
