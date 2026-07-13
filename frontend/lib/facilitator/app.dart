import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/design_system/theme/facilitator_theme.dart';
import 'router/facilitator_router.dart';

class FacilitatorApp extends ConsumerWidget {
  const FacilitatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(facilitatorRouterProvider),
      theme: FacilitatorTheme.lightTheme,
      darkTheme: FacilitatorTheme.darkTheme,
    );
  }
}
