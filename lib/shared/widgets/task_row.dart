import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/format.dart';
import '../../data/models/task.dart';
import 'priority_pill.dart';
import 'status_pill.dart';

class TaskRow extends StatelessWidget {
  const TaskRow({super.key, required this.task, this.onTap});

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final barColor = PriorityPill.colorFor(task.priority);

    return Container(
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.m),
        boxShadow: AppShadows.soft,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.m),
        child: Material(
          color: context.palette.surface,
          child: InkWell(
            onTap: onTap,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 5, color: barColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
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
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: context.palette.hint,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              StatusPill(status: task.status),
                              const SizedBox(width: 10),
                              if (task.priority != null)
                                PriorityPill(priority: task.priority!),
                              const Spacer(),
                              if (task.dueDate != null) _DueLabel(task: task),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DueLabel extends StatelessWidget {
  const _DueLabel({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final days = daysUntil(task.dueDate);
    final closed = isClosedStatus(task.status);
    final isToday = days == 0 && !closed;
    final overdue = days != null && days < 0 && !closed;

    final color = isToday
        ? AppColors.orange
        : overdue
        ? AppColors.danger
        : context.palette.muted;

    final text = isToday
        ? 'Today'
        : closed || days == null
        ? fmtShort(task.dueDate!)
        : '${fmtShort(task.dueDate!)} · ${days}d';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today_outlined, size: 12.5, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
