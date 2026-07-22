import 'dart:async';
import 'dart:typed_data';

import 'package:cornermon/admin/features/track_bulk_manage/track_csv_export.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

typedef ShareCsv = Future<void> Function(ShareParams params);

/// 플랫폼 공유를 감싸 테스트에서 실제 공유 시트를 열지 않도록 한다.
final trackPinCsvShareProvider = Provider<ShareCsv>((ref) {
  return (params) async {
    await SharePlus.instance.share(params);
  };
});

final trackPinExportControllerProvider =
    AsyncNotifierProvider<TrackPinExportController, void>(
      TrackPinExportController.new,
    );

/// 전체 트랙 PIN 조회, CSV 생성, 플랫폼 공유를 하나의 사용자 액션으로 관리한다.
class TrackPinExportController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> exportAndShare(CampId campId) async {
    state = const AsyncLoading();
    final request = exportAllTracksCsvProvider(campId);
    final subscription = ref.listen(request, (_, _) {});
    try {
      final response = await ref.read(request.future);
      final bytes = buildTrackPinCsvBytes(response.tracks ?? const []);
      await ref.read(trackPinCsvShareProvider)(
        ShareParams(
          files: [
            XFile.fromData(Uint8List.fromList(bytes), mimeType: 'text/csv'),
          ],
          fileNameOverrides: ['track-pins.csv'],
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
}
