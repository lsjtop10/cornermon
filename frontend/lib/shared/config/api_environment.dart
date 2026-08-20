/// 앱이 붙는 API 배포. `demo`는 App Store 심사/스태프 연습용 review 배포를 가리키며,
/// UI 진입점(롱프레스)으로만 전환된다 — 자세한 배경은
/// `frontend/docs/artifacts/plan/20260820_앱스토어_심사용_데모환경_프론트_plan_.md` 참고.
enum ApiEnvironment { production, demo }
