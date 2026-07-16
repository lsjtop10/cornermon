import 'package:cornermon/admin/theme/admin_theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ShouldToggleAdminThemeModeFromCurrentBrightness', () {
    // arrange
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // act / assert
    expect(container.read(adminThemeModeProvider), ThemeMode.system);
    container.read(adminThemeModeProvider.notifier).toggle(Brightness.light);
    expect(container.read(adminThemeModeProvider), ThemeMode.dark);
    container.read(adminThemeModeProvider.notifier).toggle(Brightness.dark);
    expect(container.read(adminThemeModeProvider), ThemeMode.light);
  });
}
