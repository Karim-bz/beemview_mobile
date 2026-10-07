import 'package:flutter/material.dart';

import '../../core/status_labels.dart';

/// Small colored pill that renders a status label using the shared
/// [StatusLabels] mapping (label text + accent color).
///
/// Handles all statuses seen across projects and tasks.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    if (status == null || status!.isEmpty) {
      return const SizedBox.shrink();
    }

    final color = StatusLabels.color(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        StatusLabels.label(status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
