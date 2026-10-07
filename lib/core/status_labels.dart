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
        return const Color(0xFF2599C0);
      case 'review':
        return const Color(0xFF0EA5E9);
      case 'on_hold':
        return const Color(0xFFE5A100);
      case 'done':
        return const Color(0xFF2E9E5B);
      case 'blocked':
        return const Color(0xFFB00020);
      case 'changes_requested':
        return const Color(0xFFDB2777);
      case 'canceled':
        return const Color(0xFF6B7280);
      default:
        return Colors.grey;
    }
  }
}