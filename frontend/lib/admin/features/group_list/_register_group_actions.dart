import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/badge_providers.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// QR 프레임에서 배지 payload 문자열만 뽑아내는 순수 로직. 카메라/컨트롤러
/// 라이프사이클(스캔 중지, dispose 레이스 등)은 다이얼로그(위젯) 쪽 책임.
String? extractBadgePayload(BarcodeCapture capture) =>
    capture.barcodes.firstOrNull?.rawValue;

/// 조 등록 API를 호출하고 성공 시 목록을 invalidate한다. 성공 여부만 반환하고
/// 에러 메시지 표시·다이얼로그 닫기 같은 뷰 반응은 호출부(다이얼로그)가 결정한다.
Future<bool> registerGroup(
  WidgetRef ref, {
  required CampId campId,
  required String payload,
  required String name,
}) async {
  try {
    await ref.read(
      scanRegisterBadgeProvider(campId.value, payload, name).future,
    );
    ref.invalidate(groupListProvider(campId));
    return true;
  } catch (_) {
    return false;
  }
}
