import 'package:flutter/material.dart';

import '../../../core/colors.dart';
import '../../../core/format.dart';
import '../../../data/models/project.dart';
import '../../../data/models/task.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/initials_avatar.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../../l10n/app_strings.dart';

class ProjectOverview extends StatefulWidget {
  const ProjectOverview({
    super.key,
    required this.name,
    required this.project,
    required this.tasks,
  });

  final String name;
  final Project? project;

  /// Live task list once loaded; falls back to the project's embedded tasks.
  final List<Task>? tasks;

  @override
  State<ProjectOverview> createState() => ProjectOverviewState();
}

class ProjectOverviewState extends State<ProjectOverview> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;

    // Use live tasks when available, otherwise use the tasks embedded
    // in the project payload.
    final embeddedTasks = project?.tasks ?? const <ProjectTaskLite>[];

    final total =
        widget.tasks?.length ?? (project?.taskCount ?? embeddedTasks.length);

    final description = project?.description?.trim() ?? '';

    final unit = project?.organizationalUnit;
    final unitName = unit?.name;

    // Assignees from both project-level data and tasks.
    final names = <String>{
      ...?project?.assigneeNames,
      ...?widget.tasks?.expand((t) => t.assignees.map((a) => a.fullName)),
      ...embeddedTasks.expand((t) => t.assigneeNames),
    }.where((n) => n.trim().isNotEmpty).toList();

    // Priority statistics.
    final priorities = <String, int>{};

    if (widget.tasks != null) {
      for (final task in widget.tasks!) {
        final priority = task.priority?.toLowerCase();
        if (priority != null && priority.isNotEmpty) {
          priorities[priority] = (priorities[priority] ?? 0) + 1;
        }
      }
    } else {
      for (final task in embeddedTasks) {
        final priority = task.priority?.toLowerCase();
        if (priority != null && priority.isNotEmpty) {
          priorities[priority] = (priorities[priority] ?? 0) + 1;
        }
      }
    }

    // Find the next upcoming task.
    final upcomingTasks = widget.tasks != null
        ? widget.tasks!
              .where((t) => !isClosedStatus(t.status) && t.dueDate != null)
              .map(
                (t) => ProjectTaskLite(
                  id: t.id,
                  name: t.name,
                  priority: t.priority,
                  status: t.status,
                  dueDate: t.dueDate,
                ),
              )
              .toList()
        : embeddedTasks
              .where((t) => !isClosedStatus(t.status) && t.dueDate != null)
              .toList();

    upcomingTasks.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    final ProjectTaskLite? nextDueTask = upcomingTasks.isEmpty
        ? null
        : upcomingTasks.first;

    final nextDueDate = nextDueTask?.dueDate;
    final nextDueTaskName = nextDueTask?.name;

    return AppCard(
      padding: const EdgeInsets.all(16),
      radius: AppRadius.l,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------------
          // Header
          // ------------------------------------------------------------
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: InitialsAvatar.colorFor(widget.name),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  InitialsAvatar.initialsOf(widget.name, twoLetters: true),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.projectLabel,
                      style: TextStyle(
                        fontSize: 10.5,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w800,
                        color: context.palette.muted,
                      ),
                    ),
                    Text(
                      widget.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (unitName != null && unitName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        unitName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: context.palette.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              StatusPill(status: project?.status),
            ],
          ),

          // ------------------------------------------------------------
          // Project description
          // ------------------------------------------------------------
          if (description.isNotEmpty) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                setState(() => _expanded = !_expanded);
              },
              child: Text(
                description,
                maxLines: _expanded ? null : 3,
                overflow: _expanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: context.palette.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          // ------------------------------------------------------------
          // Extra project information
          // ------------------------------------------------------------
          if (total > 0) ...[
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.palette.track.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Next deadline
                  if (nextDueDate != null) ...[
                    _InfoRow(
                      icon: Icons.event_outlined,
                      label: context.l10n.nextDeadline,
                      value: _formatProjectDate(nextDueDate),
                      valueColor: (daysUntil(nextDueDate) ?? 0) < 0
                          ? AppColors.danger
                          : null,
                    ),
                    if (nextDueTaskName != null) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 30),
                          child: Text(
                            nextDueTaskName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: context.palette.muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],

                  if (nextDueDate != null &&
                      (priorities.isNotEmpty || names.isNotEmpty))
                    const SizedBox(height: 10),

                  // Priority distribution
                  if (priorities.isNotEmpty)
                    _InfoRow(
                      icon: Icons.flag_outlined,
                      label: context.l10n.priority,
                      value: priorities.entries
                          .map((e) => '${context.l10n.priorityLabel(e.key)} ${e.value}')
                          .join(' • '),
                      maxLines: 3,
                    ),

                  if (priorities.isNotEmpty && names.isNotEmpty)
                    const SizedBox(height: 10),

                  // Assignees
                  if (names.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 18,
                          color: context.palette.muted,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          context.l10n.assignees,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.palette.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        AvatarStack(names: names, max: 4, total: names.length),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatProjectDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final target = DateTime(date.year, date.month, date.day);

    final difference = target.difference(today).inDays;

    if (difference == 0) {
      return context.l10n.today;
    }

    if (difference == 1) {
      return context.l10n.tomorrow;
    }

    if (difference == -1) {
      return context.l10n.yesterday;
    }

    if (difference < 0) {
      return context.l10n.daysOverdue(difference.abs());
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.maxLines,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.palette.muted),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: context.palette.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
