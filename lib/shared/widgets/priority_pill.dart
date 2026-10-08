import 'package:flutter/material.dart';

class PriorityPill extends StatelessWidget {
  const PriorityPill({
    super.key,
    required this.priority,
    this.filled = false,
  });

  /// Lowercase API value: low | medium | high | urgent
  final String priority;

  /// `true` = tinted chip (task details); `false` = flag + text only (lists).
  final bool filled;

  static Color colorFor(String? p) {
    switch (p?.toLowerCase()) {
      case 'urgent':
        return const Color(0xFFE5484D);
      case 'high':
        return const Color(0xFFF2683C);
      case 'medium':
        return const Color(0xFFF0A02B);
      case 'low':
        return const Color(0xFF2FA37A);
      default:
        return const Color(0xFF7C8B99);
    }
  }

  static String labelFor(String p) =>
      p.isEmpty ? '—' : p[0].toUpperCase() + p.substring(1).toLowerCase();

  @override
  Widget build(BuildContext context) {
    final color = colorFor(priority);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.outlined_flag_rounded, size: filled ? 15 : 14, color: color),
        const SizedBox(width: 4),
        Text(
          labelFor(priority),
          style: TextStyle(
            fontSize: filled ? 12.5 : 11.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );

    if (!filled) return content;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: content,
    );
  }
}
