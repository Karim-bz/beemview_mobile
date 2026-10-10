import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_strings.dart';

/// Keeps the theme choice (system, light or dark) and saves it on the phone.
class ThemeProvider extends ChangeNotifier {
  static const _key = 'theme_mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  /// Reads the saved choice. Call it once before the app starts.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _mode = _decode(prefs.getString(_key));
    } catch (_) {
      // Keep the default (follow the system) if storage is not available.
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (_) {
      // The choice still applies for this session.
    }
  }

  static ThemeMode _decode(String? value) {
    return ThemeMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}

String themeModeLabel(AppStrings s, ThemeMode mode) {
  switch (mode) {
    case ThemeMode.system:
      return s.themeSystem;
    case ThemeMode.light:
      return s.themeLight;
    case ThemeMode.dark:
      return s.themeDark;
  }
}
