import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';

part 'track_direct_actions_provider.g.dart';

@riverpod
class TrackDirectActions extends _$TrackDirectActions {
  @override
  void build(TrackId trackId) {}

  /// POST /tracks/{trackId}/messages — 발신자 role은 서버가 세션(TrackAuth)으로 판단한다.
  ///
  /// 이 provider는 위젯이 watch하지 않고 `.notifier`로만 잠깐 읽힌다. autoDispose라 리스너가
  /// 0인 채로 곧 폐기될 수 있으므로, 폐기된 뒤에도 안전한 이 POST 호출만 여기서 담당하고
  /// 후속 invalidate는 호출자(화면)의 ref가 맡는다 — 그 ref만 화면이 떠있는 동안 살아있다고
  /// 보장되기 때문이다(issue #143 후속: 전송은 성공했는데 실패로 보이거나 목록이 갱신되지
  /// 않던 문제).
  Future<void> send(String content) async {
    await ref.read(sendDirectMessageProvider(trackId, content).future);
  }
}
