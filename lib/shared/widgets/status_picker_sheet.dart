import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/status_labels.dart';

/// Status values that can be selected from the details screen.
const kSelectableTaskStatuses = <String>[
  'to_do',
  'in_progress',
  'on_hold',
  'review',
  'changes_requested',
  'blocked',
  'done',
  'canceled',
];

/// Shows a bottom sheet letting the user pick a status.
/// Returns the selected status, or null if cancelled.
Future<String?> showStatusPicker(
  BuildContext context, {
  required String? current,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            const SheetHandle(),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Change status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 10),
            for (final s in kSelectableTaskStatuses)
              _StatusOptionTile(
                status: s,
                selected: s == current,
                onTap: () => Navigator.of(context).pop(s),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 44,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFD9E0E8),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

class _StatusOptionTile extends StatelessWidget {
  const _StatusOptionTile({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  final String status;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = StatusLabels.color(status);
    final plain = status == 'to_do';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? AppColors.tealTint : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.m),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.m),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: plain
                        ? Colors.transparent
                        : color.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    StatusLabels.icon(status),
                    size: 20,
                    color: plain ? AppColors.muted : color,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    StatusLabels.label(status),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? AppColors.tealDark : AppColors.ink,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_rounded,
                    color: AppColors.teal,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
