import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/design_system/widgets/empty_state.dart';

import 'audit_log_page_notifier.dart';
import 'widgets/audit_log_filter_bar.dart';
import 'widgets/audit_log_load_more.dart';
import 'widgets/audit_log_table.dart';

/// A13 감사 로그 — plan §2 전체(UC-1 필터 조회, UC-5 실패 행 강조).
class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(auditLogPageNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('감사 로그')),
      body: Column(
        children: [
          const AuditLogFilterBar(),
          const Divider(height: 1),
          Expanded(
            child: pageState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  EmptyState(message: '감사 로그를 불러오지 못했습니다.\n$error'),
              data: (state) => SingleChildScrollView(
                child: Column(
                  children: [
                    AuditLogTable(logs: state.logs),
                    AuditLogLoadMore(nextCursor: state.nextCursor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
