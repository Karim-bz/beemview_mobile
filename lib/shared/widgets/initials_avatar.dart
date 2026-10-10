import 'package:flutter/material.dart';

import '../../core/colors.dart';

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.radius = 18});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: colorFor(name),
      child: Text(
        initialsOf(name),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.72,
        ),
      ),
    );
  }

  /// "Hani Abderrazak" -> "HA". With [twoLetters], a single word gives its
  /// first two letters ("Beem" -> "BE"); otherwise just the first.
  static String initialsOf(String name, {bool twoLetters = false}) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      final w = parts.first;
      return (twoLetters && w.length > 1 ? w.substring(0, 2) : w[0])
          .toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  /// Deterministic brand color from the name.
  static Color colorFor(String name) {
    const palette = [AppColors.teal, AppColors.orange, AppColors.green];
    if (name.isEmpty) return palette.first;
    final hash = name.codeUnits.fold<int>(0, (a, b) => a + b);
    return palette[hash % palette.length];
  }
}

/// Overlapping avatars with a white ring, plus a "+N" overflow bubble.
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.names,
    this.max = 2,
    this.total,
    this.radius = 12,
  });

  final List<String> names;
  final int max;

  /// Total number of people (defaults to names.length).
  final int? total;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final shown = names.take(max).toList();
    final extra = (total ?? names.length) - shown.length;
    final count = shown.length + (extra > 0 ? 1 : 0);
    if (count == 0) return const SizedBox.shrink();

    const ring = 2.0;
    final size = (radius + ring) * 2;
    final step = size * 0.68;

    Widget bubble(Widget child) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.palette.surface,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(ring),
      child: child,
    );

    final children = <Widget>[
      for (var i = 0; i < shown.length; i++)
        Positioned(
          left: i * step,
          child: bubble(InitialsAvatar(name: shown[i], radius: radius)),
        ),
      if (extra > 0)
        Positioned(
          left: shown.length * step,
          child: bubble(
            CircleAvatar(
              radius: radius,
              backgroundColor: AppColors.green,
              child: Text(
                '+$extra',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: radius * 0.7,
                ),
              ),
            ),
          ),
        ),
    ];

    return SizedBox(
      width: (count - 1) * step + size,
      height: size,
      child: Stack(clipBehavior: Clip.none, children: children),
    );
  }
}
