# Phase 01 — Admin API 코드젠 파이프라인 복구 및 provider 계층 재정비 (compact)

## 요구사항
`frontend/openapitools.json`이 삭제된 `api/openapi.yaml`을 가리키고 있어 코드 생성이 실패,
생성된 `lib/shared/api/gen`도 2026-07-13 이후 계약 변경(SSE 캠프 격리, 공지 경로 이동, A7 삭제
등)을 반영 못 한 상태. 코드젠을 `api/swagger.yaml` 기준으로 복구하고, 기존 9개 provider 파일이
호출하는 구버전 엔드포인트를 현재 계약에 맞게 전부 수정.

## 왜 이렇게 했는가
- **실전 버그 발견**: 재생성 후 `flutter analyze`는 통과하지만 `cornermon_api_gen`을 path
  dependency로 소비하는 모든 실행 경로(`flutter test`, 앱 실행)가 `language version override`
  에러로 컴파일 단계에서 깨짐(gen 패키지의 `.dart`/`.g.dart`가 암묵적 언어 버전을 다르게 해석하는
  것으로 추정, standalone 실행 시엔 재현 안 됨) — `scripts/patch_gen_language_version.sh`로 모든
  파일에 `// @dart=2.18` pragma를 명시 삽입해 해결. analyze 통과만으로는 이 문제를 못 잡으므로
  주의 필요.
- `dart run build_runner build`를 frontend 루트에서 실행하면 `lib/shared/api/gen`의 `.g.dart`가
  실제로 삭제되는 사고가 재현됨 확인 — 반드시 `cd lib/shared/api/gen`한 뒤 그 안에서만 재생성.
- `createCornersWithTracks`(배열로 코너 여러 개를 한 번에 만드는 provider)는 실제 계약과 불일치해
  삭제 — `POST /corners`는 단건 생성만 지원, 대량 생성 엔드포인트 없음(03에서 최종 확정).
  A0-b 마법사는 `createCorner`+`createTracksForCorner`를 코너 개수만큼 순차 호출하는 것으로 결정.
- `trackMessageList`의 `background` 기본값을 `false`로 둠 — 파라미터 없이 호출하면 상대측 미확인
  메시지가 읽음 처리되는데(09 §2.7 확정), 진행자 앱의 기존 호출부(자기 스레드 열람)는 읽음 처리가
  맞는 동작이라 기본값을 유지. 관리자 좌측 목록(미리보기, 읽음 처리되면 안 됨)만 명시적으로
  `background: true`를 넘기도록 구분.
- 기기 등록·관리자 인증·트랙 잠금해제/강제로그아웃이 계획과 달리 실제로는 하나의 생성 클래스
  `AAuthDeviceTrustApi`로 묶여 나와, 신규 파일 2개를 만드는 대신 기존
  `auth_device_trust_providers.dart`에 통합(계획 변경).
- `domain_aliases.dart`(계획에 없던 신규 파일)를 추가 — 재생성된 모델명이 전부
  `Request`/`Response` 접미사를 가져(`CampResponse` 등) 기존 plan 문서들이 전제한 짧은 도메인
  이름(`api.Camp`)과 어긋나므로, 매 plan을 다시 쓰는 대신 `typedef` 별칭 파일 하나로 흡수.
