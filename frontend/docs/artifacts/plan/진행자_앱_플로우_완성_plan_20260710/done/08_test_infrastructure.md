# Phase 08 — 테스트 인프라 및 전체 자동화 테스트 (compact)

## 요구사항
`frontend/test/`가 처음 생기는 Phase — Riverpod override + fake Dio 기반 unit/widget 테스트
인프라 구축, 모든 신규 provider/화면이 실 네트워크 없이 검증되도록 함(실기기 통합테스트는 범위 밖).

## 왜 이렇게 했는가
- 워크플로우 세션 제한으로 중단됐던 일부 테스트(라우터, QR스캔, 수동처리, 다이렉트메시지)를
  재개 시점에 직접 작성해 채움.
- 구현 중 발견한 이슈 수정: `flutter_riverpod` 3.3.2에서 `Override` 타입이
  `package:flutter_riverpod/misc.dart`로만 노출되는 점, `extension type` ID가 const 생성자가
  아닌 점을 반영.
