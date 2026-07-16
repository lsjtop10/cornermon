/// 백엔드가 계약은 확정했지만 아직 501을 반환하는 엔드포인트를 위한 표시 전용 예외.
/// 화면은 이 타입만 특별 취급해 스낵바 에러 대신 안내 문구를 보여준다.
class NotImplementedException implements Exception {
  const NotImplementedException(this.featureFlag);
  final String featureFlag;
}
