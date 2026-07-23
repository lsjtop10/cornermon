import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cornermon/admin/features/track_bulk_manage/track_excel_export.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/export/export_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

typedef ShareFile = Future<void> Function(ShareParams params);

/// 플랫폼 공유를 감싸 테스트에서 실제 공유 시트를 열지 않도록 한다.
final trackPinExportShareProvider = Provider<ShareFile>((ref) {
  return (params) async {
    await SharePlus.instance.share(params);
  };
});

final trackPinExportControllerProvider =
    AsyncNotifierProvider<TrackPinExportController, void>(
      TrackPinExportController.new,
    );

/// 전체 트랙 PIN 조회, XLSX 생성, 플랫폼 공유를 하나의 사용자 액션으로 관리한다.
class TrackPinExportController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> exportAndShare(
    CampId campId, {
    Rect? sharePositionOrigin,
  }) async {
    state = const AsyncLoading();
    final request = exportAllTrackPinsProvider(campId);
    final subscription = ref.listen(request, (_, _) {});
    try {
      final response = await ref.read(request.future);
      final bytes = buildTrackPinWorkbookBytes(response.tracks ?? const []);
      await ref.read(trackPinExportShareProvider)(
        ShareParams(
          files: [
            XFile.fromData(
              Uint8List.fromList(bytes),
              mimeType:
                  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            ),
          ],
          fileNameOverrides: ['track-pins.xlsx'],
          sharePositionOrigin: sharePositionOrigin,
          subject: '트랙 PIN 목록',
        ),
      );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } finally {
      subscription.close();
    }
  }

  /// 전체 PIN XLSX를 생성한 뒤 사용자가 선택한 기기 위치에 저장한다.
  Future<ExportSaveResult?> exportAndSave(CampId campId) async {
    state = const AsyncLoading();
    final request = exportAllTrackPinsProvider(campId);
    final subscription = ref.listen(request, (_, _) {});
    ExportSaveResult? result;
    try {
      final response = await ref.read(request.future);
      final bytes = Uint8List.fromList(
        buildTrackPinWorkbookBytes(response.tracks ?? const []),
      );
      result = await ref.read(saveExportFileProvider)(
        ExportFile.xlsx(name: 'track-pins', bytes: bytes),
      );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } finally {
      subscription.close();
    }
    return result;
  }
}
