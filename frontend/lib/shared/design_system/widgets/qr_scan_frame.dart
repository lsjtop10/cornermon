import 'package:flutter/material.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';

/// 카메라 프리뷰 위 스캔 가이드 프레임(진행자 B3, 관리자 조 등록 카메라 QR 탭 공용) —
/// 상태(대기/성공/실패)에 따라 테두리색만 바뀜.
enum QrScanFrameState { scanning, success, failure }

class QrScanFrame extends StatelessWidget {
  const QrScanFrame({required this.state, this.size = 240.0, super.key});

  final QrScanFrameState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    Color borderColor;
    Widget? icon;
    final iconSize = size / 240.0 * 64.0;

    switch (state) {
      case QrScanFrameState.scanning:
        borderColor = colors.textSecondary;
        icon = null;
        break;
      case QrScanFrameState.success:
        borderColor = colors.statusIdle;
        icon = Icon(
          Icons.check_circle,
          color: colors.statusIdle,
          size: iconSize,
        );
        break;
      case QrScanFrameState.failure:
        borderColor = colors.statusAlert;
        icon = Icon(Icons.error, color: colors.statusAlert, size: iconSize);
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 3.0),
        borderRadius: BorderRadius.circular(16.0),
      ),
      alignment: Alignment.center,
      child: icon,
    );
  }
}
