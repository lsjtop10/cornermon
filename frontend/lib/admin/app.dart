import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/router/admin_router.dart';
import 'package:cornermon/admin/theme/admin_theme_mode_provider.dart';
import 'package:cornermon/shared/design_system/theme/admin_theme.dart';

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      theme: AdminTheme.lightTheme,
      darkTheme: AdminTheme.darkTheme,
      themeMode: ref.watch(adminThemeModeProvider),
      routerConfig: ref.watch(adminRouterProvider),
    );
  }
}
