import 'package:flutter/material.dart';

import '../../../core/colors.dart';
import '../../../core/status_labels.dart';

/// Status values that can be selected from the details screen.
/// (Same list used for filters on the tasks list.)
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
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Change status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final s in kSelectableTaskStatuses)
            _StatusOptionTile(
              status: s,
              selected: s == current,
              onTap: () => Navigator.of(context).pop(s),
            ),
          const SizedBox(height: 8),
        ],
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                StatusLabels.label(status),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.beemBlue : Colors.black87,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check, color: AppColors.beemBlue, size: 18),
          ],
        ),
      ),
    );
  }
}
