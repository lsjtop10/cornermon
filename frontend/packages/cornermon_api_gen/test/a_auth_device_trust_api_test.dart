import 'package:test/test.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';


/// tests for AAuthDeviceTrustApi
void main() {
  final instance = CornermonApiGen().getAAuthDeviceTrustApi();

  group(AAuthDeviceTrustApi, () {
    // 관리자 로그인
    //
    // 관리자 ID/비밀번호로 로그인하여 액세스 토큰과 리프레시 토큰을 발급받는다.
    //
    //Future<AdminLoginResponse> authAdminLoginPost(AdminLoginRequest request) async
    test('test authAdminLoginPost', () async {
      // TODO
    });

    // 관리자 로그아웃
    //
    // 현재 활성화된 리프레시 토큰(세션)을 취소(Revoke)한다.
    //
    //Future authAdminLogoutPost() async
    test('test authAdminLogoutPost', () async {
      // TODO
    });

    // 관리자 액세스 토큰 재발급
    //
    // 리프레시 토큰으로 새 액세스 토큰을 발급한다.
    //
    //Future<AdminRefreshResponse> authAdminRefreshPost() async
    test('test authAdminRefreshPost', () async {
      // TODO
    });

    // 관리자 세션 목록 조회
    //
    // 현재 로그인된 관리자 세션 목록을 반환한다.
    //
    //Future<BuiltList<AdminSessionResponse>> authAdminSessionsGet() async
    test('test authAdminSessionsGet', () async {
      // TODO
    });

    // 관리자 세션 강제 종료
    //
    // 특정 관리자 세션을 강제 만료 처리한다.
    //
    //Future authAdminSessionsIdRevokePost(String id) async
    test('test authAdminSessionsIdRevokePost', () async {
      // TODO
    });

    // 디바이스 락아웃 해제
    //
    // 관리자가 PIN 다회 오류로 잠긴 기기를 해제한다.
    //
    //Future authTrackLockoutDeviceIdReleasePost(String deviceId) async
    test('test authTrackLockoutDeviceIdReleasePost', () async {
      // TODO
    });

    // 진행자 트랙 PIN 로그인
    //
    // 신뢰 기기에서 트랙 PIN 으로 로그인하여 트랙 세션 토큰을 발급받는다.
    //
    //Future<TrackLoginResponse> authTrackLoginPost(TrackLoginRequest request) async
    test('test authTrackLoginPost', () async {
      // TODO
    });

    // 진행자 트랙 로그아웃
    //
    // 트랙 진행자가 스스로 로그아웃한다.
    //
    //Future authTrackLogoutPost() async
    test('test authTrackLogoutPost', () async {
      // TODO
    });

    // 활성 진행자 세션 목록 조회
    //
    // 캠프 내 취소되지 않은(active) 진행자 세션 목록을 조회한다.
    //
    //Future<BuiltList<FacilitatorSessionResponse>> authTrackSessionsGet(String campId) async
    test('test authTrackSessionsGet', () async {
      // TODO
    });

    // 트랙 강제 로그아웃
    //
    // 관리자가 특정 트랙의 진행자 세션을 강제 종료시킨다.
    //
    //Future authTrackTrackIdForceLogoutPost(String trackId) async
    test('test authTrackTrackIdForceLogoutPost', () async {
      // TODO
    });

    // 기기 등록 목록 조회
    //
    // 관리자가 등록되었거나 대기 중인 기기 목록을 확인한다.
    //
    //Future<BuiltList<DeviceRegistrationResponse>> deviceRegistrationsGet() async
    test('test deviceRegistrationsGet', () async {
      // TODO
    });

    // 기기 승인
    //
    // PENDING 상태인 기기를 APPROVED로 승인한다.
    //
    //Future<DeviceRegistrationResponse> deviceRegistrationsIdApprovePost(String id) async
    test('test deviceRegistrationsIdApprovePost', () async {
      // TODO
    });

    // 기기 거절
    //
    // PENDING 상태인 기기를 REJECTED로 거절한다.
    //
    //Future<DeviceRegistrationResponse> deviceRegistrationsIdRejectPost(String id) async
    test('test deviceRegistrationsIdRejectPost', () async {
      // TODO
    });

    // 기기 신뢰 취소 (폐기/분실)
    //
    // APPROVED 기기의 권한을 REVOKED로 박탈한다.
    //
    //Future<DeviceRegistrationResponse> deviceRegistrationsIdRevokePost(String id) async
    test('test deviceRegistrationsIdRevokePost', () async {
      // TODO
    });

    // 잠금 기기 목록 조회
    //
    // 캠프 내 PIN 연속 실패로 잠금된(APPROVED, LockedUntil이 미래) 기기 목록을 조회한다.
    //
    //Future<BuiltList<DeviceRegistrationResponse>> deviceRegistrationsLockedGet(String campId) async
    test('test deviceRegistrationsLockedGet', () async {
      // TODO
    });

    // 내 기기 등록 상태 자체 조회
    //
    // 미승인(PENDING) 기기가 자신의 승인 상태를 확인하기 위해 호출한다.
    //
    //Future<BuiltMap<String, JsonObject>> deviceRegistrationsMeGet() async
    test('test deviceRegistrationsMeGet', () async {
      // TODO
    });

    // 기기 등록 요청 (최초 앱 실행 시)
    //
    // 기기가 서버에 등록을 요청한다. 이후 관리자의 승인 대기.
    //
    //Future<DeviceRegistrationResponse> deviceRegistrationsPost(DeviceRegistrationRequest request) async
    test('test deviceRegistrationsPost', () async {
      // TODO
    });

  });
}
