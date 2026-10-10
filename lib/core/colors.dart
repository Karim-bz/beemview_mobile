import 'package:flutter/material.dart';

/// BeemView 360 brand colors. They look the same in light and dark mode.
/// Colors that change with the theme (backgrounds, text, borders) are in
/// [AppPalette]: read them with `context.palette`.
class AppColors {
  const AppColors._();

  static const teal = Color(0xFF1F92BC);
  static const tealDark = Color(0xFF1A7FA6);
  static const orange = Color(0xFFFF9F2E);
  static const green = Color(0xFF4FB99A);
  static const danger = Color(0xFFE5484D);

  // Legacy names kept so older call sites keep compiling.
  static const beemBlue = teal;
  static const beemOrange = orange;
}

/// Colors that depend on the theme (light or dark).
///
/// Use `context.palette.surface`, `context.palette.ink`, ... instead of
/// hard-coded colors, so every screen follows the selected theme.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.canvas,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.hint,
    required this.track,
    required this.tealTint,
    required this.dangerTint,
    required this.skyGradient,
    required this.splashGradient,
  });

  final Brightness brightness;

  /// Screen background.
  final Color canvas;

  /// Cards, sheets, fields (white in light mode).
  final Color surface;

  /// Main text color.
  final Color ink;

  /// Secondary text and icons.
  final Color muted;

  /// Placeholders and disabled elements.
  final Color hint;

  /// Borders, dividers and empty progress bars.
  final Color track;

  /// Light teal background for chips and highlights.
  final Color tealTint;

  /// Light red background for error states.
  final Color dangerTint;

  final LinearGradient skyGradient;
  final LinearGradient splashGradient;

  static const light = AppPalette(
    brightness: Brightness.light,
    canvas: Color(0xFFF4F7FB),
    surface: Colors.white,
    ink: Color(0xFF10222F),
    muted: Color(0xFF7C8B99),
    hint: Color(0xFFA3AFBB),
    track: Color(0xFFE8EEF4),
    tealTint: Color(0xFFE3F2F8),
    dangerTint: Color(0xFFFDECEC),
    skyGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFD9ECF8), Color(0xFFF4F7FB)],
    ),
    splashGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE0EFF9), Color(0xFFF8FBFE), Color(0xFFFFF3E2)],
    ),
  );

  static const dark = AppPalette(
    brightness: Brightness.dark,
    canvas: Color(0xFF0D1620),
    surface: Color(0xFF16222E),
    ink: Color(0xFFE6EDF3),
    muted: Color(0xFF9BA9B7),
    hint: Color(0xFF6C7B8A),
    track: Color(0xFF263544),
    tealTint: Color(0xFF173A4A),
    dangerTint: Color(0xFF3B1E22),
    skyGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF12303F), Color(0xFF0D1620)],
    ),
    splashGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF10242F), Color(0xFF0D1620), Color(0xFF2A2012)],
    ),
  );

  @override
  AppPalette copyWith({
    Brightness? brightness,
    Color? canvas,
    Color? surface,
    Color? ink,
    Color? muted,
    Color? hint,
    Color? track,
    Color? tealTint,
    Color? dangerTint,
    LinearGradient? skyGradient,
    LinearGradient? splashGradient,
  }) {
    return AppPalette(
      brightness: brightness ?? this.brightness,
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      hint: hint ?? this.hint,
      track: track ?? this.track,
      tealTint: tealTint ?? this.tealTint,
      dangerTint: dangerTint ?? this.dangerTint,
      skyGradient: skyGradient ?? this.skyGradient,
      splashGradient: splashGradient ?? this.splashGradient,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      hint: Color.lerp(hint, other.hint, t)!,
      track: Color.lerp(track, other.track, t)!,
      tealTint: Color.lerp(tealTint, other.tealTint, t)!,
      dangerTint: Color.lerp(dangerTint, other.dangerTint, t)!,
      skyGradient: t < 0.5 ? skyGradient : other.skyGradient,
      splashGradient: t < 0.5 ? splashGradient : other.splashGradient,
    );
  }
}

/// Short access to the current palette: `context.palette.surface`.
extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}

class AppRadius {
  const AppRadius._();
  static const double s = 12;
  static const double m = 16;
  static const double l = 22;
  static const double xl = 30;
}

class AppShadows {
  const AppShadows._();

  /// Soft, borderless card shadow.
  static List<BoxShadow> soft = [
    BoxShadow(
      color: const Color(0xFF10222F).withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glow(Color c) => [
    BoxShadow(
      color: c.withValues(alpha: 0.35),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

class AppGradients {
  const AppGradients._();

  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2AA3CC), Color(0xFF1A86B0)],
  );
}
