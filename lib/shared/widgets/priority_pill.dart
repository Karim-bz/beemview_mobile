import 'package:flutter/material.dart';

class PriorityPill extends StatelessWidget {
  const PriorityPill({super.key, required this.priority});

  /// Lowercase API value: low | medium | high | urgent
  final String priority;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(priority);
    final label = _labelFor(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  String _labelFor(String p) =>
      p[0].toUpperCase() + p.substring(1).toLowerCase();

  Color _colorFor(String p) {
    switch (p.toLowerCase()) {
      case 'urgent':
        return const Color(0xFFB00020);
      case 'high':
        return const Color(0xFFE5573F);
      case 'medium':
        return const Color(0xFFE5A100);
      case 'low':
        return const Color(0xFF2E9E5B);
      default:
        return Colors.grey;
    }
  }
}
