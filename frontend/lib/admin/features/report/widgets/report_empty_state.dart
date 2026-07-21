import 'package:flutter/material.dart';

import 'package:cornermon/shared/design_system/widgets/empty_state.dart';

/// 코너학습 진행 중(리포트 미생성) 상태 안내 — screen-spec-admin.md A12 원문 그대로.
class ReportEmptyState extends StatelessWidget {
  const ReportEmptyState({super.key});

  @override
  Widget build(BuildContext context) => const EmptyState(
    message: '코너학습 종료 후 이용 가능',
    icon: Icons.summarize_outlined,
  );
}
