import 'package:flutter/material.dart';

/// 관리자 대시보드에서 쓰는 코너 상태 카드의 공통 골격이다.
class CornerStatusCard extends StatelessWidget {
  const CornerStatusCard({
    required this.title,
    required this.statusLabel,
    required this.statusIcon,
    required this.statusColor,
    required this.trackSummary,
    required this.durationSummary,
    this.isBottleneck = false,
    this.onTap,
    super.key,
  });

  final String title;
  final String statusLabel;
  final IconData statusIcon;
  final Color statusColor;
  final String trackSummary;
  final String durationSummary;
  final bool isBottleneck;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isBottleneck ? Colors.red : statusColor,
              width: 4,
            ),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: 6),
                Text(statusLabel),
              ],
            ),
            const SizedBox(height: 12),
            Text(trackSummary),
            const SizedBox(height: 4),
            Text(durationSummary),
          ],
        ),
      ),
    ),
  );
}
