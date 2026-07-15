import 'package:cornermon/facilitator/features/track_confirm/track_confirm_screen.dart';
import 'package:cornermon/facilitator/session/track_session_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/widget_test_helpers.dart';

/// 실제 로그인/로그아웃 API 호출 없이 confirmAssignment/rejectAssignment 호출 여부만 기록한다.
class _RecordingTrackSession extends TrackSession {
  _RecordingTrackSession(this._initial);

  final TrackSessionState _initial;
  bool confirmCalled = false;
  bool rejectCalled = false;

  @override
  TrackSessionState build() => _initial;

  @override
  Future<void> confirmAssignment() async {
    confirmCalled = true;
  }

  @override
  Future<void> rejectAssignment() async {
    rejectCalled = true;
  }
}

TrackSessionPendingConfirmation _buildPendingSession() {
  final track = Track(
    (b) => b
      ..id = 'track-1'
      ..trackNo = 3
      ..cornerId = 'corner-1'
      ..status = TrackStatus.ACTIVE
      ..operationalStatus = TrackOperationalStatus.IDLE,
  );
  final corner = AuthTrackLoginPost200ResponseCorner(
    (b) => b
      ..id = 'corner-1'
      ..name = '피자',
  );
  return TrackSessionPendingConfirmation(trackToken: 'track-token', track: track, corner: corner);
}

void main() {
  testWidgets('ShouldCallConfirmAssignmentWhenYesTapped', (tester) async {
    // arrange
    final fakeSession = _RecordingTrackSession(_buildPendingSession());
    await tester.pumpWidget(buildTestable(
      const TrackConfirmScreen(),
      overrides: [trackSessionProvider.overrideWith(() => fakeSession)],
    ));
    await tester.pump();

    // act
    await tester.tap(find.text('예, 맞습니다'));
    await tester.pump();

    // assert
    expect(fakeSession.confirmCalled, isTrue);
    expect(fakeSession.rejectCalled, isFalse);
  });

  testWidgets('ShouldCallRejectAssignmentWhenNoTapped', (tester) async {
    // arrange
    final fakeSession = _RecordingTrackSession(_buildPendingSession());
    await tester.pumpWidget(buildTestable(
      const TrackConfirmScreen(),
      overrides: [trackSessionProvider.overrideWith(() => fakeSession)],
    ));
    await tester.pump();

    // act
    await tester.tap(find.text('아니요, 다시 로그인'));
    await tester.pump();

    // assert
    expect(fakeSession.rejectCalled, isTrue);
    expect(fakeSession.confirmCalled, isFalse);
  });
}
