import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:cornermon/shared/api/sse/reconnect_backoff.dart';

/// 지터를 없애 매 호출의 delay를 결정론적으로 만드는 fake Random (항상 0을 반환 → jitterRatio 0.8x).
class _ZeroRandom implements Random {
  @override
  double nextDouble() => 0;

  @override
  bool nextBool() => false;

  @override
  int nextInt(int max) => 0;
}

void main() {
  group('ReconnectBackoff', () {
    test('ShouldDoubleDelayOnEachConsecutiveFailure', () {
      // arrange — 지터를 0.8x로 고정해 지수 증가분만 검증한다.
      final backoff = ReconnectBackoff(
        initialDelay: const Duration(milliseconds: 300),
        maxDelay: const Duration(seconds: 5),
        random: _ZeroRandom(),
      );

      // act
      final delays = List.generate(4, (_) => backoff.nextDelay());

      // assert — 300ms, 600ms, 1200ms, 2400ms에 각각 0.8배.
      expect(delays[0], const Duration(milliseconds: 240));
      expect(delays[1], const Duration(milliseconds: 480));
      expect(delays[2], const Duration(milliseconds: 960));
      expect(delays[3], const Duration(milliseconds: 1920));
    });

    test('ShouldCapDelayAtMaxDelay', () {
      // arrange
      final backoff = ReconnectBackoff(
        initialDelay: const Duration(milliseconds: 300),
        maxDelay: const Duration(seconds: 5),
        random: _ZeroRandom(),
      );

      // act — 실패를 충분히 반복해 지수 증가가 상한을 넘어서게 만든다.
      Duration? lastDelay;
      for (var i = 0; i < 10; i++) {
        lastDelay = backoff.nextDelay();
      }

      // assert — 상한(5초)의 0.8배를 넘지 않는다.
      expect(lastDelay! <= const Duration(seconds: 5), isTrue);
      expect(lastDelay, const Duration(milliseconds: 4000)); // 5000ms * 0.8
    });

    test('ShouldRestartFromInitialDelayAfterReset', () {
      // arrange
      final backoff = ReconnectBackoff(
        initialDelay: const Duration(milliseconds: 300),
        maxDelay: const Duration(seconds: 5),
        random: _ZeroRandom(),
      );
      backoff.nextDelay();
      backoff.nextDelay();
      backoff.nextDelay();

      // act
      backoff.reset();
      final delayAfterReset = backoff.nextDelay();

      // assert — reset() 후엔 다시 initialDelay(×0.8) 근처로 돌아온다.
      expect(delayAfterReset, const Duration(milliseconds: 240));
    });

    test('ShouldApplyJitterWithinConfiguredRange', () {
      // arrange — 실제 Random을 써서 매 호출마다 값이 달라지는지, 범위 안인지 확인한다.
      final backoff = ReconnectBackoff(
        initialDelay: const Duration(seconds: 1),
        maxDelay: const Duration(seconds: 5),
      );

      // act
      final delay = backoff.nextDelay();

      // assert — 1초 * [0.8, 1.2] 범위.
      expect(delay.inMilliseconds, greaterThanOrEqualTo(800));
      expect(delay.inMilliseconds, lessThanOrEqualTo(1200));
    });

    test('ShouldSkipRemainingDelayWhenReachabilityEmitsFirst', () async {
      // arrange — 아주 긴 백오프 대기 중에 reachability 이벤트가 먼저 도착하면 즉시 반환돼야 한다.
      final backoff = ReconnectBackoff(
        initialDelay: const Duration(seconds: 10),
        maxDelay: const Duration(seconds: 10),
      );
      final reachability = StreamController<void>();
      addTearDown(reachability.close);

      // act
      final future = backoff.waitOrFastRetryOn(reachability.stream);
      reachability.add(null);

      // assert — 10초를 기다리지 않고 훨씬 빨리 반환된다.
      await expectLater(future, completes).timeout(const Duration(seconds: 1));
    });

    test('ShouldWaitFullDelayWhenReachabilityNeverEmits', () async {
      // arrange
      final backoff = ReconnectBackoff(
        initialDelay: const Duration(milliseconds: 50),
        maxDelay: const Duration(milliseconds: 50),
        random: _ZeroRandom(),
      );
      final reachability = StreamController<void>();
      addTearDown(reachability.close);

      // act
      final stopwatch = Stopwatch()..start();
      await backoff.waitOrFastRetryOn(reachability.stream);
      stopwatch.stop();

      // assert — jitterRatio 0.8x이므로 40ms 근처에서 반환된다.
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(30));
    });

    test('ShouldFallBackToDelayWhenReachabilityStreamCompletesWithoutEmitting', () async {
      // arrange — 이벤트 없이 곧바로 끝나는 스트림(reachability.first가 StateError를 던지는
      // 상황)을 흉내낸다. 이 에러가 waitOrFastRetryOn 밖으로 새어나가면 재연결 루프 전체가
      // 죽어버리므로, 여기선 조용히 무시되고 nextDelay()만으로 정상 완료돼야 한다.
      final backoff = ReconnectBackoff(
        initialDelay: const Duration(milliseconds: 50),
        maxDelay: const Duration(milliseconds: 50),
        random: _ZeroRandom(),
      );

      // act & assert — 에러 없이 완료돼야 한다.
      await expectLater(
        backoff.waitOrFastRetryOn(const Stream.empty()),
        completes,
      ).timeout(const Duration(seconds: 1));
    });
  });
}
