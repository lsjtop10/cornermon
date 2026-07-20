import 'dart:async';
import 'dart:math';

/// 재연결 간격을 지수적으로 늘리며(최대 상한 있음) 소폭의 지터를 더한다.
/// reset()이 호출되기 전까지는 실패할 때마다 간격이 계속 늘어난다.
class ReconnectBackoff {
  ReconnectBackoff({
    this.initialDelay = const Duration(milliseconds: 300),
    this.maxDelay = const Duration(seconds: 5),
    Random? random,
  }) : _random = random ?? Random();

  final Duration initialDelay;
  final Duration maxDelay;
  final Random _random;
  int _attempt = 0;

  /// 연결 성공 시(onConnected) 호출 — 다음 실패는 다시 initialDelay부터 시작한다.
  void reset() => _attempt = 0;

  /// 다음 재시도까지 기다릴 시간. attempt=0(첫 실패)이면 initialDelay 근처,
  /// 실패가 반복될수록 2배씩 늘어나 maxDelay에서 상한이 걸린다. ±20% full-jitter 적용.
  Duration nextDelay() {
    final exponential = initialDelay * (1 << _attempt.clamp(0, 10));
    final capped = exponential > maxDelay ? maxDelay : exponential;
    _attempt++;
    final jitterRatio = 0.8 + _random.nextDouble() * 0.4; // 0.8x~1.2x
    return capped * jitterRatio;
  }

  /// [reachability]가 먼저 이벤트를 내보내면(=OS가 네트워크 회복/전환을 감지) 남은 백오프
  /// 대기를 포기하고 즉시 반환한다. 그렇지 않으면 nextDelay()만큼 그냥 기다린다.
  ///
  /// [reachability]가 이벤트 없이 에러나 종료로 끝나도(예: connectivity_plus 플랫폼 채널
  /// 예외) 그 실패를 밖으로 던지지 않는다 — 이 메서드가 재연결 루프의 유일한 대기 지점인데
  /// 여기서 에러가 새어나가면 루프 전체가 죽어서 다시는 재연결을 시도하지 않게 된다. 그런
  /// 경우엔 그냥 nextDelay() 타이머만으로 계속 동작한다.
  Future<void> waitOrFastRetryOn(Stream<void> reachability) {
    final never = Completer<void>().future;
    final onReachable = reachability.first.then<void>((_) {}, onError: (_) => never);
    return Future.any<void>([
      Future<void>.delayed(nextDelay()),
      onReachable,
    ]);
  }
}
