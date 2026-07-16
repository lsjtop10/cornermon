/// Riverpod 기본 `retry`는 실패한 provider를 무제한, 지수 백오프(최대 6.4초)로 재시도한다.
/// POST 계열 액션(생성/로그인 등)은 멱등이 아니라서, 성공 이후 클라이언트 쪽에서 예외가 나면
/// 이 기본 재시도가 같은 리소스를 계속 중복 생성하게 된다. 이런 provider엔 명시적으로 꺼둔다.
Duration? noRetry(int retryCount, Object error) => null;
