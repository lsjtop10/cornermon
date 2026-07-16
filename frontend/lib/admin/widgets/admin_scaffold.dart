import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/admin/widgets/sidebar/admin_sidebar.dart';
import 'package:cornermon/admin/features/start_camp/start_camp_button.dart';

class AdminScaffold extends ConsumerWidget {
  const AdminScaffold({required this.body, super.key});

  final Widget body;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCamp = ref.watch(selectedCampProvider);
    return selectedCamp.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) =>
          const Scaffold(body: Center(child: Text('캠프 정보를 불러올 수 없습니다.'))),
      data: (camp) {
        if (camp?.status == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          body: Row(
            children: [
              AdminSidebar(mode: sidebarModeFor(camp!.status!)),
              const VerticalDivider(width: 1),
              Expanded(
                child: Column(
                  children: [
                    if (sidebarModeFor(camp.status!) == SidebarMode.preparing)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: StartCampButton(),
                        ),
                      ),
                    Expanded(child: body),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
