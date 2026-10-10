import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppTheme {
  const AppTheme._();

  /// [arabic] switches to a font that has Arabic letters.
  static ThemeData light({bool arabic = false}) =>
      _build(AppPalette.light, arabic: arabic);

  static ThemeData dark({bool arabic = false}) =>
      _build(AppPalette.dark, arabic: arabic);

  static ThemeData _build(AppPalette p, {required bool arabic}) {
    final isDark = p.brightness == Brightness.dark;

    final base = ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal,
        brightness: p.brightness,
        primary: AppColors.teal,
        secondary: AppColors.orange,
        surface: p.surface,
      ),
      scaffoldBackgroundColor: p.canvas,
      extensions: [p],
    );

    return base.copyWith(
      textTheme: (arabic
              ? GoogleFonts.cairoTextTheme(base.textTheme)
              : GoogleFonts.plusJakartaSansTextTheme(base.textTheme))
          .apply(bodyColor: p.ink, displayColor: p.ink),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: p.ink,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? p.track : p.ink,
        contentTextStyle: TextStyle(color: isDark ? p.ink : Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.teal,
      ),
    );
  }
}
