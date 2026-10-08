import 'package:flutter/material.dart';

/// BeemView 360 design tokens (daylight theme).
class AppColors {
  const AppColors._();

  // Brand
  static const teal = Color(0xFF1F92BC);
  static const tealDark = Color(0xFF1A7FA6);
  static const tealTint = Color(0xFFE3F2F8);
  static const orange = Color(0xFFFF9F2E);
  static const green = Color(0xFF4FB99A);

  // Surfaces & text
  static const canvas = Color(0xFFF4F7FB);
  static const skyTop = Color(0xFFDCEEF8);
  static const ink = Color(0xFF10222F);
  static const muted = Color(0xFF7C8B99);
  static const hint = Color(0xFFA3AFBB);
  static const track = Color(0xFFE8EEF4);
  static const danger = Color(0xFFE5484D);
  static const dangerTint = Color(0xFFFDECEC);

  // Legacy names kept so older call sites keep compiling.
  static const beemBlue = teal;
  static const beemOrange = orange;
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

  static const sky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFD9ECF8), Color(0xFFF4F7FB)],
  );

  static const splash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE0EFF9), Color(0xFFF8FBFE), Color(0xFFFFF3E2)],
  );
}
