import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/design_system/tokens/colors.dart';
import '../../shared/design_system/tokens/spacing.dart';
import '../../shared/design_system/tokens/typography.dart';

const int _pinLength = 6;

/// design-system.md §4.6 — 화면에 보이지 않는 input 1개 + 6칸 표시 전용.
/// 칸마다 별도 input을 두면 포커스 이동 시 네이티브 키보드가 깜빡이므로 이 구조를 쓴다.
class PinOtpInput extends StatefulWidget {
  const PinOtpInput({required this.onSubmitted, this.enabled = true, super.key});

  final ValueChanged<String> onSubmitted;
  final bool enabled;

  @override
  State<PinOtpInput> createState() => _PinOtpInputState();
}

class _PinOtpInputState extends State<PinOtpInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleChanged);
  }

  @override
  void didUpdateWidget(covariant PinOtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled) {
      _focusNode.unfocus();
    }
  }

  void _handleChanged() {
    final text = _controller.text;
    setState(() {}); // 표시용 박스 리렌더

    if (text.length == _pinLength) {
      widget.onSubmitted(text);
      // 다음 입력이 빈 화면에서 시작되도록 즉시 비운다(로그인 실패 후 재입력 대비).
      _controller.clear();
    }
  }

  void _requestFocus() {
    if (widget.enabled) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final text = _controller.text;
    final activeIndex = widget.enabled && text.length < _pinLength ? text.length : -1;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _requestFocus,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _pinLength; i++) ...[
                if (i > 0) SizedBox(width: AppSpacing.space2),
                _PinBox(
                  character: i < text.length ? text[i] : null,
                  isActive: i == activeIndex,
                  enabled: widget.enabled,
                  colors: colors,
                ),
              ],
            ],
          ),
          // 실제 입력을 받는 유일한 요소 — 화면 밖으로 보내 숨긴다.
          Offstage(
            child: SizedBox(
              width: 1,
              height: 1,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                autofocus: false,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_pinLength),
                ],
                showCursor: false,
                decoration: const InputDecoration(border: InputBorder.none),
                style: const TextStyle(color: Colors.transparent),
                cursorColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinBox extends StatelessWidget {
  const _PinBox({
    required this.character,
    required this.isActive,
    required this.enabled,
    required this.colors,
  });

  final String? character;
  final bool isActive;
  final bool enabled;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final borderColor = !enabled
        ? colors.textDisabled
        : isActive
            ? colors.brandPrimary
            : colors.border;
    final textColor = enabled ? colors.textPrimary : colors.textDisabled;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 44.0,
      height: 52.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: enabled ? colors.bgSurface : colors.bgSurfaceRaised,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: borderColor,
          width: isActive ? 2.0 : 1.0,
        ),
      ),
      child: Text(
        character ?? '',
        style: AppTypography.title2.copyWith(color: textColor),
      ),
    );
  }
}
