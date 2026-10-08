import 'package:flutter/material.dart';

import '../../core/status_labels.dart';

/// Small tinted pill that renders a status label.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.status,
    this.onTap,
    this.showChevron = false,
    this.large = false,
  });

  final String? status;
  final VoidCallback? onTap;

  /// Shows a dropdown chevron (used on the task details screen).
  final bool showChevron;
  final bool large;

  @override
  Widget build(BuildContext context) {
    if (status == null || status!.isEmpty) return const SizedBox.shrink();

    final color = StatusLabels.color(status);
    final pill = Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            StatusLabels.label(status),
            style: TextStyle(
              fontSize: large ? 12.5 : 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (showChevron) ...[
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: color),
          ],
        ],
      ),
    );

    if (onTap == null) return pill;
    return GestureDetector(onTap: onTap, child: pill);
  }
}
