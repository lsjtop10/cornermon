import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminThemeModeProvider = NotifierProvider<AdminThemeMode, ThemeMode>(
  AdminThemeMode.new,
);

class AdminThemeMode extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void toggle(Brightness currentBrightness) => state =
      currentBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
}
