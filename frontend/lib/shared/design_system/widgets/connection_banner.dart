import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

enum ConnectionBannerState { hidden, reconnecting, disconnected }

class ConnectionBanner extends StatefulWidget {
  const ConnectionBanner({
    required this.state,
    super.key,
  });

  final ConnectionBannerState state;

  @override
  State<ConnectionBanner> createState() => _ConnectionBannerState();
}

class _ConnectionBannerState extends State<ConnectionBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    if (widget.state != ConnectionBannerState.hidden) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ConnectionBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == ConnectionBannerState.hidden) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state == ConnectionBannerState.hidden && _controller.isDismissed) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    Color bgColor;
    Color textColor;
    Widget icon;
    String message;

    if (widget.state == ConnectionBannerState.reconnecting) {
      bgColor = isDark ? const Color(0xFF2E333D) : const Color(0xFFE2E5EA);
      textColor = colors.textPrimary;
      icon = SizedBox(
        width: 16.0,
        height: 16.0,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          color: textColor,
        ),
      );
      message = '재연결 시도 중…';
    } else {
      // ignore: deprecated_member_use
      bgColor = colors.warning.withOpacity(isDark ? 0.25 : 0.15);
      textColor = colors.warning;
      icon = Icon(Icons.wifi_off_rounded, color: textColor, size: 18.0);
      message = '연결이 끊겼습니다 · 최근 상태를 보여주고 있어요';
    }

    return SizeTransition(
      sizeFactor: _heightFactor,
      // ignore: deprecated_member_use
      axisAlignment: -1.0,
      child: Container(
        width: double.infinity,
        color: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8.0),
            Flexible(
              child: Text(
                message,
                style: AppTypography.caption.copyWith(color: textColor, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
