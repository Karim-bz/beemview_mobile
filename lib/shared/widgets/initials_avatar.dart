import 'package:flutter/material.dart';

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.radius = 18});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _colorFrom(name),
      child: Text(
        _initials(name),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.75,
        ),
      ),
    );
  }

  /// "Karim Bouzid" → "KA", "Karim" → "K".
  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  /// Deterministic color from the name — same name always gets the
  /// same color, so avatars don't flicker between rebuilds.
  static Color _colorFrom(String name) {
    const palette = [
      Color(0xFF2599C0), // brand blue
      Color(0xFF10B981), // emerald
      Color(0xFF8B5CF6), // violet
      Color(0xFFF59E0B), // amber
      Color(0xFFEF4444), // red
      Color(0xFF0EA5E9), // sky
    ];
    if (name.isEmpty) return palette.first;
    final hash = name.codeUnits.fold<int>(0, (a, b) => a + b);
    return palette[hash % palette.length];
  }
}
