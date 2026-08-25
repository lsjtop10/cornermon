# 관리자 역할 도입 + 초기 관리자 부트스트랩 + 관리자 계정 관리 API (compact)

## 요구사항
`admins` 테이블과 로그인/세션 로직은 있지만 최초 관리자 계정을 만들 방법이 시스템 어디에도 없음
(`Save` 없음, seed 없음, 회원가입 API 없음). 서버 최초 기동 시 ENV 기반 시스템 관리자 시딩,
역할(SYSTEM_ADMIN/CORNER_OPERATOR) 도입, 관리자 생성/비밀번호변경/삭제 API 구현.

## 정책 확정 사항 (사용자 확답, 코드로는 복원 안 되는 정책 결정)
- SYSTEM_ADMIN은 다른 SYSTEM_ADMIN을 생성할 수 없음 — 생성 API는 CORNER_OPERATOR 생성만 허용.
- 생성/삭제는 SYSTEM_ADMIN 전용이지만, **비밀번호 변경은 본인 또는 SYSTEM_ADMIN** 둘 다 가능
  (처음엔 SYSTEM_ADMIN 전용으로 계획했다가 사용자 피드백으로 변경).
- 자기 자신 삭제 방지, 마지막 SYSTEM_ADMIN 삭제 방지 가드는 범위에 포함(처음엔 범위 불확실했다가
  사용자 피드백으로 포함 확정).
- ENV 미설정 + `admins` 테이블이 비어있으면 조용히 넘어가지 않고 `log.Fatalf`로 서버 기동 자체를
  중단 — "관리자 없는 서버"가 조용히 배포되는 운영 사고를 막기 위함.

## 왜 이렇게 했는가
- 역할 인가 로직을 핸들러가 아니라 usecase(`authorizeSystemAdmin`/`authorizeSelfOrSystemAdmin`)
  에만 두도록 강제 — 핸들러가 role/본인 여부 분기를 우회할 수 없게 하기 위함.
- 관리자 삭제 시 세션은 별도 무효화 호출 없이 `admin_sessions.admin_id ON DELETE CASCADE`로
  DB 레벨에서 정리 — 기존 스키마 제약을 그대로 재사용.
- 새 서비스를 신설하지 않고 기존 `AdminAuthService`를 확장(기존 포트 활용 우선 원칙).
