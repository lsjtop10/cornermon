import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

enum TrackVisualStatus { idle, busy, alert, inactive }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.status,
    this.label,
    super.key,
  });

  final TrackVisualStatus status;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    Color statusColor;
    String symbol;
    String defaultLabel;

    switch (status) {
      case TrackVisualStatus.idle:
        statusColor = colors.statusIdle;
        symbol = '○';
        defaultLabel = '유휴';
        break;
      case TrackVisualStatus.busy:
        statusColor = colors.statusBusy;
        symbol = '●';
        defaultLabel = '진행중';
        break;
      case TrackVisualStatus.alert:
        statusColor = colors.statusAlert;
        symbol = '▲';
        defaultLabel = '지연';
        break;
      case TrackVisualStatus.inactive:
        statusColor = colors.statusInactive;
        symbol = '✕';
        defaultLabel = '미가동';
        break;
    }

    final displayLabel = label ?? defaultLabel;
    final opacity = isDark ? 0.20 : 0.12;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: statusColor.withOpacity(opacity),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            symbol,
            style: AppTypography.label.copyWith(
              color: statusColor,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 4.0),
          Text(
            displayLabel,
            style: AppTypography.label.copyWith(
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
