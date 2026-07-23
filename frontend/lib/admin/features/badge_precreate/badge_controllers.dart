import 'dart:async';
import 'dart:typed_data';

import 'package:cornermon/admin/features/badge_precreate/badge_sticker_pdf.dart';
import 'package:cornermon/shared/api/providers/badge_providers.dart';
import 'package:cornermon/shared/export/export_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

typedef SharePdf =
    Future<bool> Function({required Uint8List bytes, required String filename});

final badgePdfShareProvider = Provider<SharePdf>((ref) => Printing.sharePdf);

final badgeGenerateControllerProvider =
    AsyncNotifierProvider<BadgeGenerateController, void>(
      BadgeGenerateController.new,
    );

class BadgeGenerateController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}
  Future<void> generate(int count) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(bulkGenerateBadgesProvider(count).future);
      ref.invalidate(badgeListProvider);
    });
  }
}

final badgeExportControllerProvider =
    AsyncNotifierProvider<BadgeExportController, bool>(
      BadgeExportController.new,
    );

class BadgeExportController extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() => false;
  Future<bool> exportAndShare() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final badges = await ref.read(exportUnassignedBadgesProvider.future);
      if (badges.isEmpty) return false;
      final bytes = await buildBadgeStickerPdf(badges);
      await ref.read(badgePdfShareProvider)(
        bytes: bytes,
        filename:
            'cornermon-badges-${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      return true;
    });
    return state.value ?? false;
  }

  /// 미배정 배지 PDF를 기기 저장 위치 선택기에 저장한다.
  ///
  /// null은 내보낼 미배정 배지가 없는 경우이고, cancelled는 사용자가 선택기를
  /// 닫은 정상 흐름이다.
  Future<ExportSaveResult?> exportAndSave() async {
    state = const AsyncLoading();
    ExportSaveResult? result;
    state = await AsyncValue.guard(() async {
      final badges = await ref.read(exportUnassignedBadgesProvider.future);
      if (badges.isEmpty) return false;
      final bytes = await buildBadgeStickerPdf(badges);
      result = await ref.read(saveExportFileProvider)(
        ExportFile.pdf(
          name: 'cornermon-badges-${DateTime.now().millisecondsSinceEpoch}',
          bytes: bytes,
        ),
      );
      return true;
    });
    return state.hasError ? null : result;
  }
}
