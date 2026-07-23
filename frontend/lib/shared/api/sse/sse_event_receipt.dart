import 'package:cornermon_api_gen/cornermon_api_gen.dart';

/// 동일 payload도 각각의 수신 사실을 보존하는 SSE 전달 단위.
///
/// 서버 알림에는 발생 ID가 없어서 같은 scope의 연속 이벤트가 값 동등할 수 있다. 이 객체는
/// identity equality를 유지하므로 Riverpod의 상태 listener가 매 수신을 독립 이벤트로 본다.
class SseEventReceipt {
  const SseEventReceipt({required this.sequence, required this.notification});

  final int sequence;
  final SSENotification notification;
}
