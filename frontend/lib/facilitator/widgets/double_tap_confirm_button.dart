import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';

/// B2 종료확인 — 첫 탭은 무장(armed)만, armDuration 안에 재탭해야 onConfirmed 호출.
class DoubleTapConfirmButton extends StatefulWidget {
  const DoubleTapConfirmButton({
    required this.label,
    required this.armedLabel,
    required this.onConfirmed,
    this.armDuration = const Duration(seconds: 3),
    super.key,
  });

  final String label;
  final String armedLabel;
  final VoidCallback onConfirmed;
  final Duration armDuration;

  @override
  State<DoubleTapConfirmButton> createState() => _DoubleTapConfirmButtonState();
}

class _DoubleTapConfirmButtonState extends State<DoubleTapConfirmButton> {
  bool _armed = false;
  Timer? _revertTimer;

  @override
  void dispose() {
    _revertTimer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    if (_armed) {
      // 2차 탭 — 타이머 취소하고 정확히 1회 확정 콜백, 다음 사용을 위해 즉시 원상태 복귀.
      _revertTimer?.cancel();
      _revertTimer = null;
      setState(() => _armed = false);
      widget.onConfirmed();
      return;
    }

    // 1차 탭 — 무장 상태로 전환, armDuration 안에 재탭 없으면 콜백 없이 자동 해제.
    setState(() => _armed = true);
    _revertTimer = Timer(widget.armDuration, () {
      if (!mounted) return;
      setState(() => _armed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_armed) {
      return AppButton(
        variant: AppButtonVariant.primary,
        label: widget.label,
        onPressed: _handleTap,
      );
    }

    // AppButton에 warning variant가 없어 무장 상태는 별도로 스타일링.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Material(
      color: colors.warning,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Center(
            widthFactor: 1.0,
            child: Text(
              widget.armedLabel,
              style: AppTypography.bodyEmphasis.copyWith(color: colors.quiet),
            ),
          ),
        ),
      ),
    );
  }
}
