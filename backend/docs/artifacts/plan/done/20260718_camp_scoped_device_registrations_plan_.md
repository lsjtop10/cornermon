# 캠프 범위 기기 등록 API 정리 (compact)

## 요구사항
관리자용 기기 등록 조회·관리 API가 최상위 경로 + `campId` 쿼리 파라미터로 돼 있어 라우터
구조와 불일치. `/camps/{campId}/device-registrations` 하위 리소스로 이동해 정리.
