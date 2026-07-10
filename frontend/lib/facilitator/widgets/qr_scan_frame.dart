import 'package:flutter/material.dart';
import '../../shared/design_system/tokens/colors.dart';

/// B3 카메라 프리뷰 위 스캔 가이드 프레임 — 상태(대기/성공/실패)에 따라 테두리색만 바뀜.
enum QrScanFrameState { scanning, success, failure }

class QrScanFrame extends StatelessWidget {
  const QrScanFrame({required this.state, super.key});

  final QrScanFrameState state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    Color borderColor;
    Widget? icon;

    switch (state) {
      case QrScanFrameState.scanning:
        borderColor = colors.textSecondary;
        icon = null;
        break;
      case QrScanFrameState.success:
        borderColor = colors.statusIdle;
        icon = Icon(Icons.check_circle, color: colors.statusIdle, size: 64.0);
        break;
      case QrScanFrameState.failure:
        borderColor = colors.statusAlert;
        icon = Icon(Icons.error, color: colors.statusAlert, size: 64.0);
        break;
    }

    return Container(
      width: 240.0,
      height: 240.0,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 3.0),
        borderRadius: BorderRadius.circular(16.0),
      ),
      alignment: Alignment.center,
      child: icon,
    );
  }
}
