import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/format.dart';
import '../../data/models/task.dart';
import '../../shared/widgets/states.dart';
import '../../shared/widgets/task_row.dart';
import '../auth/auth_provider.dart';
import '../projects/projects_provider.dart';
import '../shell/main_shell.dart';
import '../task_details/task_details_screen.dart';

/// "My tasks" tab: open tasks assigned to the signed-in user.
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = context.watch<ProjectsProvider>();
    final userId = context.watch<AuthProvider>().user?.id;
    final tasks = projects.myOpenTasks(userId);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tasks',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                  if (tasks.isNotEmpty)
                    Text(
                      '${tasks.length} open · ${_dueTodayCount(tasks)} due today',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: _body(context, projects, tasks)),
          ],
        ),
      ),
    );
  }

  static int _dueTodayCount(List<Task> tasks) =>
      tasks.where((t) => daysUntil(t.dueDate) == 0).length;

  Widget _body(BuildContext context, ProjectsProvider p, List<Task> tasks) {
    switch (p.status) {
      case ProjectsStatus.idle:
      case ProjectsStatus.loading:
        return const LoadingView(message: 'Loading tasks...');
      case ProjectsStatus.error:
        return ErrorView(
          message: p.error ?? 'Failed to load tasks.',
          onRetry: () => p.load(),
        );
      case ProjectsStatus.loaded:
        if (tasks.isEmpty) return const _EmptyTasks();
        return RefreshIndicator(
          onRefresh: () => p.load(),
          child: _TaskList(tasks: tasks),
        );
    }
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Task>>{};
    for (final t in tasks) {
      final d = daysUntil(t.dueDate);
      final key = d == null
          ? 'No due date'
          : d < 0
          ? 'Overdue'
          : d == 0
          ? 'Today'
          : 'Upcoming';
      groups.putIfAbsent(key, () => []).add(t);
    }

    final children = <Widget>[];
    for (final key in const ['Overdue', 'Today', 'Upcoming', 'No due date']) {
      final list = groups[key];
      if (list == null) continue;
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 0, 10),
          child: Text(
            key,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: key == 'Overdue' ? AppColors.danger : AppColors.muted,
            ),
          ),
        ),
      );
      for (final t in list) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TaskRow(
              task: t,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      TaskDetailsScreen(taskId: t.id, initialTask: t),
                ),
              ),
            ),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: children,
    );
  }
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _ChecklistIllustration(),
            const SizedBox(height: 24),
            const Text(
              'Nothing on your plate',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tasks assigned to you will show up here.\n'
              'Pick a project to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 22),
            TextButton(
              onPressed: () => shellIndex.value = 0,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.teal,
                backgroundColor: AppColors.tealTint,
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.m),
                ),
              ),
              child: const Text(
                'Browse projects',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft cloud blob with a checklist card and a few sparkles.
class _ChecklistIllustration extends StatelessWidget {
  const _ChecklistIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 190,
            height: 130,
            decoration: BoxDecoration(
              color: AppColors.tealTint,
              borderRadius: BorderRadius.circular(70),
            ),
          ),
          Positioned(
            right: 24,
            top: 2,
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFFD6ECF6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: 78,
            height: 96,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppShadows.soft,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _row(AppColors.teal, checked: true),
                _row(AppColors.green, checked: true),
                _row(AppColors.orange, checked: false),
              ],
            ),
          ),
          const Positioned(
            left: 18,
            top: 14,
            child: Icon(Icons.auto_awesome, size: 18, color: AppColors.teal),
          ),
          const Positioned(
            right: 14,
            top: 0,
            child: Icon(Icons.auto_awesome, size: 22, color: AppColors.orange),
          ),
          Positioned(left: 26, bottom: 28, child: _dot(AppColors.orange, 6)),
          Positioned(right: 22, bottom: 36, child: _dot(AppColors.green, 7)),
        ],
      ),
    );
  }

  Widget _row(Color c, {required bool checked}) => Row(
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: checked ? c : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: c, width: 1.8),
        ),
        child: checked
            ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
            : null,
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Container(
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.track,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    ],
  );

  Widget _dot(Color c, double s) => Container(
    width: s,
    height: s,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}
