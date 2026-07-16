import 'package:cornermon/admin/features/badge_precreate/badge_controllers.dart';
import 'package:cornermon/shared/api/providers/badge_providers.dart';
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
}
