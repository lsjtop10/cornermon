/// 로그 레벨. `debug`/`info`는 개발 중 진단용이라 release 빌드 콘솔·링버퍼 어디에도
/// 남기지 않는다. `warn`/`error`는 필드 사후진단(#131)의 대상이라 release에서도
/// [LogRingBuffer]에 항상 적재된다 — 자세한 정책은 §레벨 정책(2026-07-22 플랜 문서) 참고.
enum LogLevel { debug, info, warn, error }
