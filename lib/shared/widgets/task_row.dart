import 'package:flutter/material.dart';

import '../../../data/models/task.dart';
import 'initials_avatar.dart';
import 'priority_pill.dart';
import 'status_pill.dart';

class TaskRow extends StatelessWidget {
  const TaskRow({super.key, required this.task, this.onTap});

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                StatusPill(status: task.status),
                const SizedBox(width: 8),
                if (task.priority != null)
                  PriorityPill(priority: task.priority!),
              ],
            ),
            if (task.assignees.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final a in task.assignees.take(3))
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: InitialsAvatar(name: a.fullName, radius: 12),
                    ),
                  if (task.assignees.length > 3)
                    Text(
                      '+${task.assignees.length - 3}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
            ],
            if (task.dueDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.event_rounded, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Due ${_formatDate(task.dueDate!)}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
