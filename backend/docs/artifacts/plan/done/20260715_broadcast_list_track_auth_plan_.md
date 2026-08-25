# 공지사항 목록 조회(ListBroadcasts) TrackAuth 허용 (compact)

## 요구사항
`GET /camps/{campId}/messages/broadcast`가 admin 그룹에만 등록돼 있어 진행자(Track) 세션은
401. 진행자 앱도 자기 캠프 공지 목록을 조회해야 함.

## 왜 이렇게 했는가
- 이전 설계안(`AnnouncementUsecase.GetCampIDByTrack` 추가 후 트랙-캠프 스코프 검증)은 폐기 —
  세션 유효성은 미들웨어가 이미 보장하고, 공지는 트랙 개인정보가 아닌 캠프 단위 공개 정보라
  usecase 계층에 스코프 검증 책임을 추가할 필요가 없다고 판단.
- 핸들러 로직은 손대지 않고 라우팅만 admin 그룹에서 `MessageAuthMiddleware`(Admin+Track 모두
  허용)를 쓰는 `message` 그룹으로 이동 — Echo가 동일 method+path를 두 그룹에 중복 등록할 수
  없어서 이동이 유일한 방법.
