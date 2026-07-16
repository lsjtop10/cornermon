import 'dart:async';

import 'package:cornermon/admin/features/badge_precreate/badge_sticker_pdf.dart';
import 'package:cornermon/shared/api/providers/badge_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

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
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'cornermon-badges-${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      return true;
    });
    return state.value ?? false;
  }
}
