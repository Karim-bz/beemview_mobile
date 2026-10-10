import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_strings.dart';

/// Keeps the language choice (system, English or Arabic) and saves it.
class LocaleProvider extends ChangeNotifier {
  static const _key = 'app_language';

  /// null = follow the phone language.
  Locale? _locale;
  Locale? get locale => _locale;

  /// Language really used: the saved choice, else the phone language when it
  /// is supported, else English.
  Locale get effective {
    final code = (_locale ?? PlatformDispatcher.instance.locale).languageCode;
    return Locale(code == 'ar' ? 'ar' : 'en');
  }

  bool get isArabic => effective.languageCode == 'ar';

  /// Texts in the current language, for code that has no BuildContext
  /// (for example the API client).
  AppStrings get strings => AppStrings.forLocale(effective);

  /// Reads the saved choice. Call it once before the app starts.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _locale = _decode(prefs.getString(_key));
    } catch (_) {
      // Keep the default (follow the phone language).
    }
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale?.languageCode == _locale?.languageCode) return;
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.remove(_key);
      } else {
        await prefs.setString(_key, locale.languageCode);
      }
    } catch (_) {
      // The choice still applies for this session.
    }
  }

  static Locale? _decode(String? value) {
    switch (value) {
      case 'en':
        return const Locale('en');
      case 'ar':
        return const Locale('ar');
      default:
        return null;
    }
  }
}

/// Name of a language, written in that language ("System" follows the app).
String languageLabel(AppStrings s, Locale? locale) {
  switch (locale?.languageCode) {
    case 'en':
      return 'English';
    case 'ar':
      return 'العربية';
    default:
      return s.themeSystem;
  }
}
