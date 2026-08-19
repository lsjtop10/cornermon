import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/router/admin_router.dart';
import 'package:cornermon/admin/session/admin_event_coordinator.dart';
import 'package:cornermon/admin/theme/admin_theme_mode_provider.dart';
import 'package:cornermon/admin/widgets/admin_scaffold_messenger_key.dart';
import 'package:cornermon/shared/design_system/theme/admin_theme.dart';
import 'package:cornermon/shared/design_system/widgets/connection_banner.dart';

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      scaffoldMessengerKey: adminScaffoldMessengerKey,
      theme: AdminTheme.lightTheme,
      darkTheme: AdminTheme.darkTheme,
      themeMode: ref.watch(adminThemeModeProvider),
      routerConfig: ref.watch(adminRouterProvider),
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR')],
      // material_ui의 GlobalMaterialLocalizations.delegates는 Widgets/Cupertino
      // delegate를 함께 묶어 제공한다(Flutter 3.47, material_ui 1.0 표준 설정).
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) {
        final bannerState = ref.watch(adminConnectionBannerStateProvider);
        return Column(
          children: [
            ConnectionBanner(state: bannerState),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        );
      },
    );
  }
}
