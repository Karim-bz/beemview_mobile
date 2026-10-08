import 'package:flutter/material.dart';

/// Central mapping for task/project status values.
class StatusLabels {
  const StatusLabels._();

  static String label(String? status) {
    switch (status) {
      case 'planning':
        return 'Planning';
      case 'to_do':
        return 'To do';
      case 'in_progress':
        return 'In progress';
      case 'review':
        return 'Review';
      case 'on_hold':
        return 'Paused';
      case 'done':
        return 'Completed';
      case 'blocked':
        return 'Blocked';
      case 'changes_requested':
        return 'Changes requested';
      case 'canceled':
        return 'Canceled';
      default:
        if (status == null || status.isEmpty) return '—';
        final spaced = status.replaceAll('_', ' ');
        return spaced[0].toUpperCase() + spaced.substring(1);
    }
  }

  /// Accent color used for status pills.
  static Color color(String? status) {
    switch (status) {
      case 'planning':
        return const Color(0xFF7B61FF);
      case 'to_do':
        return const Color(0xFF64748B);
      case 'in_progress':
        return const Color(0xFF1F92BC);
      case 'review':
        return const Color(0xFF0EA5E9);
      case 'on_hold':
        return const Color(0xFFF0A02B);
      case 'done':
        return const Color(0xFF2FA37A);
      case 'blocked':
        return const Color(0xFFE5484D);
      case 'changes_requested':
        return const Color(0xFFDB2777);
      case 'canceled':
        return const Color(0xFF6B7280);
      default:
        return Colors.grey;
    }
  }

  /// Compact label for tight chips ("Changes requested" -> "Changes").
  static String shortLabel(String? status) =>
      status == 'changes_requested' ? 'Changes' : label(status);

  /// Icon shown in the status picker.
  static IconData icon(String? status) {
    switch (status) {
      case 'to_do':
        return Icons.radio_button_unchecked_rounded;
      case 'in_progress':
        return Icons.contrast_rounded;
      case 'on_hold':
        return Icons.pause_circle_outline_rounded;
      case 'review':
        return Icons.visibility_outlined;
      case 'changes_requested':
        return Icons.published_with_changes_rounded;
      case 'blocked':
        return Icons.block_rounded;
      case 'done':
        return Icons.check_circle_outline_rounded;
      case 'canceled':
        return Icons.cancel_outlined;
      default:
        return Icons.circle_outlined;
    }
  }
}
