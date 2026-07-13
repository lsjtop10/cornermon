# cornermon

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 실행 방법 (환경변수 주입)

API base URL, HTTP 타임아웃, SSE 하트비트 워치독 타임아웃은 `lib/shared/config/app_env.dart`의
`AppEnv`에서 `--dart-define`(-from-file)로 컴파일 타임에 주입됩니다. 인자 없이 실행하면 로컬 개발 기본값
(`http://localhost/api/v1`, 5초, 40초)이 그대로 적용됩니다.

```bash
# 기본값 그대로 실행
flutter run

# 파일 기반으로 여러 값을 한 번에 주입
flutter run --dart-define-from-file=env/dev.json

# 개별 값만 오버라이드
flutter run --dart-define=API_BASE_URL=https://staging.example.com/api/v1
```
