# 코너학습 운영 시스템 — 화면별 구성 명세 (인덱스)

> 화면 수가 두 플랫폼 합쳐 30개에 가까워지며 파일 하나가 너무 길어져 플랫폼별로 분리했다.

- **[screen-spec-admin.md](screen-spec-admin.md)** — 관리자 앱(iPad, A0~A15)
- **[screen-spec-facilitator.md](screen-spec-facilitator.md)** — 진행자 앱(모바일, B0~B8)

각 화면은 **목적 / 레이아웃 / 구성 요소 / 상태(States) / 연동 API / 관련 시나리오**로 기술한다. §domain-model.md / §scenarios.md / §api-endpoints.md 기반. 시각 스타일(색상/타이포/컴포넌트)은 [design-system.md](../design-system.md) 참고.

플랫폼: **관리자 = iPad(가로 우선)**, **진행자 = 모바일(iOS/Android, 세로)**.

---

## 두 문서 공통으로 남은 확인 필요 사항

- 실제 캠프 브랜드 컬러가 확정되면 design-system.md §1.1의 플레이스홀더 값을 교체할 것.
- 캠프 상태(PENDING→ACTIVE→ENDED, domain-model.md §2.0-a)의 PENDING→ACTIVE 전이는 관리자의 명시적 액션("코너학습 시작", A0-e)으로 결정됐다 — 상세는 [screen-spec-admin.md](screen-spec-admin.md) A0-c/A0-e 참고. 코너·트랙이 하나도 없는 채로 시작을 확정할 수 있는지는 아직 미정.

플랫폼별 나머지 확인 필요 사항은 각 문서 하단을 참고.
