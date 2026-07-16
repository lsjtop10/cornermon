import 'package:cornermon/admin/features/camp_list/camp_list_screen.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

CampResponse _camp(String id, String name, CampResponseStatusEnum status) =>
    CampResponse(
      (b) => b
        ..id = id
        ..name = name
        ..status = status,
    );

void main() {
  testWidgets('ShoudRenderOnlyNonEmptySectionsWhenCampsAreGrouped', (
    tester,
  ) async {
    // arrange
    final active = [_camp('active-1', '진행 캠프', CampResponseStatusEnum.ACTIVE)];
    final pending = [
      _camp('pending-1', '준비 캠프', CampResponseStatusEnum.PENDING),
    ];

    // act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              CampSection(status: api.CampStatus.ACTIVE, camps: active),
              CampSection(status: api.CampStatus.PENDING, camps: pending),
              const CampSection(status: api.CampStatus.ENDED, camps: []),
            ],
          ),
        ),
      ),
    );

    // assert
    expect(find.text('진행 중'), findsNWidgets(2));
    expect(find.text('준비 중'), findsNWidgets(2));
    expect(find.text('종료됨'), findsNothing);
    expect(find.text('진행 캠프'), findsOneWidget);
    expect(find.text('준비 캠프'), findsOneWidget);
  });
}
