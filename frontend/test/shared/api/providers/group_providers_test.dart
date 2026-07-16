import 'package:cornermon/shared/api/client/api_client.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_utils/widget_test_helpers.dart';

void main() {
  test('ShoudReturnGeneratedGroupDtosWhenGroupListProviderReadsApi', () async {
    // arrange
    final dio = buildFakeDio((request) {
      expect(request.path, '/camps/camp-1/groups');
      return [
        [
          'id',
          'group-1',
          'name',
          '1조',
          'status',
          'IDLE_MOVING',
          'isFinished',
          false,
          'itinerary',
          <Object?>[],
        ],
      ];
    });
    final container = buildContainer(
      overrides: [apiClientProvider.overrideWith((ref) => dio)],
    );
    addTearDown(container.dispose);

    // act
    final groups = await container.read(
      groupListProvider(CampId('camp-1')).future,
    );

    // assert
    expect(groups, hasLength(1));
    expect(groups.single.id, 'group-1');
    expect(groups.single.name, '1조');
  });
}
