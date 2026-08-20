import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'api_environment.dart';

part 'active_api_environment_provider.g.dart';

/// 현재 선택된 API 환경. `apiClientProvider`가 이 값을 watch해 base URL을 결정하므로,
/// `keepAlive: true`로 둬야 앱 전체에서 단일 소스로 유지된다 — `apiClientProvider`와 동일한
/// 이유(§2.1 DEVELOPER_GUIDE, "공유 인프라는 keepAlive로 고정").
///
/// 앱 재시작 후에는 항상 운영으로 되돌아간다(영속화하지 않음) — 심사/연습 세션은 한 번의
/// 앱 실행 안에서 끝나는 게 보통이고, 재시작마다 다시 운영을 기본값으로 보는 편이
/// 실캠프 사용자가 잘못 데모 환경에 머무는 사고를 구조적으로 막는다.
@Riverpod(keepAlive: true)
class ActiveApiEnvironment extends _$ActiveApiEnvironment {
  @override
  ApiEnvironment build() => ApiEnvironment.production;

  void switchTo(ApiEnvironment next) => state = next;
}
