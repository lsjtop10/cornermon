import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/visit_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';

import 'package:cornermon/facilitator/session/track_session_provider.dart';
import 'package:cornermon/facilitator/widgets/qr_scan_frame.dart';

/// B3 — QR 스캔(입장 전용). 퇴장은 트랙당 진행중 방문이 1개뿐이라 B2에서 바로 처리하고
/// 이 화면을 거치지 않는다(§domain-model 2.6-d).
class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key});

  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  QrScanFrameState _frameState = QrScanFrameState.scanning;
  bool _busy = false; // 연속 프레임 중복 스캔 방지

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  TrackId get _trackId {
    final session = ref.read(trackSessionProvider);
    if (session is! TrackSessionAuthenticated) {
      throw StateError('QR 스캔은 인증된 트랙 세션에서만 가능합니다.');
    }
    return TrackId(session.track.id!);
  }

  void _onDetect(BarcodeCapture capture) {
    final token = capture.barcodes.firstOrNull?.rawValue;
    if (token == null || _busy) return;
    _busy = true;
    unawaited(_handleToken(token));
  }

  Future<void> _handleToken(String token) async {
    try {
      await ref.read(visitActionsProvider(_trackId).notifier).startByQr(token);
      if (!mounted) return;
      setState(() => _frameState = QrScanFrameState.success);
      unawaited(HapticFeedback.mediumImpact());
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      context.pop(); // 성공 → B2로 복귀
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _frameState = QrScanFrameState.failure);
      await _showFailure(e);
      if (!mounted) return;
      setState(() => _frameState = QrScanFrameState.scanning);
      _busy = false; // 바텀시트 닫힘 후 스캔 재개
    }
  }

  /// ErrorResponse.code → 안내 문구 매핑(screen-spec B3 그대로).
  String _messageFor(DioException e) {
    final data = e.response?.data;
    final body = data is Map ? data : null;
    final code = body?['code'] as String?;
    switch (code) {
      case 'DUPLICATE_VISIT':
        return '이미 완료된 코너입니다';
      case 'TRACK_BUSY':
        return '현재 진행중인 조가 있습니다';
      case 'GROUP_AT_CORNER':
        return '이 조는 현재 다른 코너에서 진행 중입니다';
      default:
        return '방문을 시작하지 못했습니다';
    }
  }

  Future<void> _showFailure(DioException e) {
    final message = _messageFor(e);
    return showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final colors = isDark ? AppColors.dark : AppColors.light;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: colors.statusAlert, size: 40.0),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  message,
                  style: AppTypography.title3.copyWith(
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space6),
                AppButton(
                  variant: AppButtonVariant.primary,
                  size: AppButtonSize.comfortable,
                  width: AppButtonWidth.fill,
                  label: '확인',
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space6),
                  child: Text(
                    '카메라를 사용할 수 없습니다. 설정에서 카메라 권한을 허용해주세요.',
                    style: AppTypography.body.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Center(child: QrScanFrame(state: _frameState)),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space4),
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    '취소',
                    style: AppTypography.bodyEmphasis.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space6),
                child: TextButton(
                  onPressed: () => context.go('/main/manual'),
                  child: Text(
                    '수동 입력으로 전환',
                    style: AppTypography.body.copyWith(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
