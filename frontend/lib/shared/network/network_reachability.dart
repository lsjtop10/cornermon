import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_reachability.g.dart';

/// [stream]은 "네트워크가 쓸 수 있는 상태로 바뀜" 이벤트만 걸러낸 broadcast 스트림이다.
/// `@riverpod Stream&lt;void&gt;`로 직접 선언하지 않는 이유: 그렇게 하면 Riverpod이 이 provider를
/// StreamProvider(AsyncValue&lt;void&gt; 래핑)로 취급해 원시 Stream을 꺼낼 방법이 없어진다
/// (riverpod 3.x는 `.stream` modifier를 제공하지 않음). 그래서 평범한 값 provider로 감싼다.
class NetworkReachability {
  NetworkReachability(this.stream);

  final Stream<void> stream;
}

/// connectivity_plus의 원시 이벤트(예: none→wifi, wifi→mobile)를 그대로 넘기지 않고,
/// "연결 가능한 상태로 바뀜"만 걸러서 내보낸다 — SSE 재연결 루프는 구체적인 인터페이스
/// 종류(wifi/mobile)에는 관심 없고 "지금 재시도해볼 만하다"는 신호만 필요하기 때문이다.
@Riverpod(keepAlive: true)
NetworkReachability networkReachability(Ref ref) {
  final connectivity = Connectivity();
  final stream = connectivity.onConnectivityChanged
      .where((results) => !results.contains(ConnectivityResult.none))
      .map((_) {});
  return NetworkReachability(stream);
}
