import 'dart:async';
import 'dart:typed_data';

import 'package:cornermon/admin/features/badge_precreate/badge_export_options.dart';
import 'package:cornermon/admin/features/badge_precreate/badge_sticker_image.dart';
import 'package:cornermon/admin/features/badge_precreate/badge_sticker_pdf.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/providers/badge_providers.dart';
import 'package:cornermon/shared/export/export_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

typedef SharePdf =
    Future<bool> Function({required Uint8List bytes, required String filename});

final badgePdfShareProvider = Provider<SharePdf>((ref) => Printing.sharePdf);

typedef ShareFiles = Future<void> Function(ShareParams params);

/// PDF와 달리 이미지 여러 장은 `Printing.sharePdf`로 공유할 수 없어 범용 공유
/// API를 별도로 감싼다.
final badgeFilesShareProvider = Provider<ShareFiles>(
  (ref) => (params) => SharePlus.instance.share(params),
);

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

  Future<bool> exportAndShare([
    BadgeExportSettings settings = const BadgeExportSettings(),
  ]) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final badges = await ref.read(exportUnassignedBadgesProvider.future);
      if (badges.isEmpty) return false;
      final stamp = DateTime.now().millisecondsSinceEpoch;
      switch (settings.format) {
        case BadgeExportFormat.pdfSheet:
          final bytes = await buildBadgeStickerPdf(
            badges,
            pageFormat: settings.paperSize.toPdfPageFormat(),
            qrSizeMm: settings.qrSizeMm,
          );
          await ref.read(badgePdfShareProvider)(
            bytes: bytes,
            filename: 'cornermon-badges-$stamp.pdf',
          );
        case BadgeExportFormat.images:
          final images = buildBadgeQrImages(
            badges,
            resolutionPx: settings.qrResolutionPx,
          );
          await ref.read(badgeFilesShareProvider)(
            ShareParams(
              files: [
                for (final bytes in images)
                  XFile.fromData(bytes, mimeType: 'image/png'),
              ],
              fileNameOverrides: [for (final badge in badges) _pngName(badge)],
            ),
          );
      }
      return true;
    });
    return state.value ?? false;
  }

  /// 미배정 배지 PDF/이미지를 기기 저장 위치 선택기에 저장한다.
  ///
  /// null은 내보낼 미배정 배지가 없는 경우이고, cancelled는 사용자가 선택기를
  /// 닫은 정상 흐름이다.
  Future<ExportSaveResult?> exportAndSave([
    BadgeExportSettings settings = const BadgeExportSettings(),
  ]) async {
    state = const AsyncLoading();
    ExportSaveResult? result;
    state = await AsyncValue.guard(() async {
      final badges = await ref.read(exportUnassignedBadgesProvider.future);
      if (badges.isEmpty) return false;
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final ExportFile file;
      switch (settings.format) {
        case BadgeExportFormat.pdfSheet:
          file = ExportFile.pdf(
            name: 'cornermon-badges-$stamp',
            bytes: await buildBadgeStickerPdf(
              badges,
              pageFormat: settings.paperSize.toPdfPageFormat(),
              qrSizeMm: settings.qrSizeMm,
            ),
          );
        case BadgeExportFormat.images:
          final images = buildBadgeQrImages(
            badges,
            resolutionPx: settings.qrResolutionPx,
          );
          file = ExportFile.zip(
            name: 'cornermon-badges-$stamp',
            bytes: buildBadgeQrImagesZip(badges, images),
          );
      }
      result = await ref.read(saveExportFileProvider)(file);
      return true;
    });
    return state.hasError ? null : result;
  }
}

String _pngName(api.Badge badge) => '${badge.shortId ?? badge.id}.png';
