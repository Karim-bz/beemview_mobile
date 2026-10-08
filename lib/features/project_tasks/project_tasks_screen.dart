import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/format.dart';
import '../../core/status_labels.dart';
import '../../data/models/project.dart';
import '../../data/models/task.dart';
import '../../shared/widgets/add_fab.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/states.dart';
import '../../shared/widgets/task_row.dart';
import '../projects/projects_provider.dart';
import 'new_task_screen.dart';
import 'project_tasks_provider.dart';
import '../task_details/task_details_screen.dart';
import 'widgets/project_overview.dart';

const _taskStatuses = <String>[
  'to_do',
  'in_progress',
  'on_hold',
  'review',
  'changes_requested',
  'blocked',
  'done',
  'canceled',
];

/// Date buckets, in display order.
enum _Bucket { overdue, today, thisWeek, later, earlier, noDate }

const _bucketTitles = {
  _Bucket.overdue: 'Overdue',
  _Bucket.today: 'Today',
  _Bucket.thisWeek: 'This week',
  _Bucket.later: 'Later',
  _Bucket.earlier: 'Earlier',
  _Bucket.noDate: 'No due date',
};

_Bucket _bucketOf(Task t) {
  final days = daysUntil(t.dueDate);
  if (days == null) return _Bucket.noDate;
  if (days == 0) return _Bucket.today;
  if (days < 0) {
    return isClosedStatus(t.status) ? _Bucket.earlier : _Bucket.overdue;
  }
  if (days <= 7) return _Bucket.thisWeek;
  return _Bucket.later;
}

class ProjectTasksScreen extends StatefulWidget {
  const ProjectTasksScreen({
    super.key,
    required this.projectId,
    required this.projectName,
    this.project,
  });

  final int projectId;
  final String projectName;

  /// Project summary from the projects list (description, status, unit...).
  final Project? project;

  @override
  State<ProjectTasksScreen> createState() => _ProjectTasksScreenState();
}

class _ProjectTasksScreenState extends State<ProjectTasksScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _statusFilter; // null = All

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectTasksProvider>().load(widget.projectId);
    });
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() => context.read<ProjectTasksProvider>().reload();

  List<Task> _applyFilters(List<Task> all) {
    return all.where((t) {
      final matchesQuery =
          _query.isEmpty || t.name.toLowerCase().contains(_query);
      final matchesStatus = _statusFilter == null || t.status == _statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  String _subtitle(List<Task> all) {
    if (all.isEmpty) return 'No tasks yet';
    final dueToday = all
        .where((t) => daysUntil(t.dueDate) == 0 && !isClosedStatus(t.status))
        .length;
    final base = '${all.length} task${all.length == 1 ? '' : 's'}';
    return dueToday > 0 ? '$base · $dueToday due today' : base;
  }

  Future<void> _openNewTask() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NewTaskScreen(
          projectId: widget.projectId,
          projectName: widget.projectName,
        ),
      ),
    );
    if (created == true && mounted) {
      // Keep the project cards' task counts in sync.
      context.read<ProjectsProvider>().refreshSilently();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Task created')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectTasksProvider>();
    return Scaffold(
      backgroundColor: AppColors.canvas,
      floatingActionButton: AddFab(onTap: _openNewTask),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const SquareBackButton(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.projectName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          _subtitle(provider.tasks),
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  Widget _searchAndChips(List<Task> all) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 2, bottom: 8),
            child: Text(
              'Filtering the tasks already loaded for this project',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ),
        ),
        SearchField(
          controller: _searchController,
          hint: 'Filter loaded tasks by name...',
        ),
        const SizedBox(height: 14),
        _buildFilterChips(all),
      ],
    );
  }

  Widget _buildFilterChips(List<Task> all) {
    final counts = <String?, int>{
      null: all.length,
      for (final s in _taskStatuses) s: all.where((t) => t.status == s).length,
    };

    final options = <String?>[
      null,
      for (final s in _taskStatuses)
        if ((counts[s] ?? 0) > 0) s,
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = options[index];
          return FilterPill(
            label: status == null ? 'All' : StatusLabels.shortLabel(status),
            count: counts[status] ?? 0,
            selected: _statusFilter == status,
            dotColor: status == null ? null : StatusLabels.color(status),
            onTap: () => setState(() => _statusFilter = status),
          );
        },
      ),
    );
  }

  Widget _buildBody(ProjectTasksProvider provider) {
    final header = ProjectOverview(
      name: widget.projectName,
      project: widget.project,
      tasks: provider.status == TasksStatus.loaded ? provider.tasks : null,
    );

    Widget scroll(List<Widget> children) => RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: children,
      ),
    );

    switch (provider.status) {
      case TasksStatus.idle:
      case TasksStatus.loading:
        return scroll([
          header,
          const SizedBox(height: 60),
          const LoadingView(message: 'Loading tasks...'),
        ]);
      case TasksStatus.error:
        return scroll([
          header,
          const SizedBox(height: 40),
          ErrorView(
            message: provider.error ?? 'Failed to load tasks.',
            onRetry: _refresh,
          ),
        ]);
      case TasksStatus.loaded:
        if (provider.tasks.isEmpty) {
          return scroll([
            header,
            const SizedBox(height: 40),
            const EmptyView(
              message: 'This project has no tasks yet.',
              icon: Icons.checklist_rounded,
            ),
          ]);
        }
        final filtered = _applyFilters(provider.tasks);
        return scroll([
          header,
          const SizedBox(height: 18),
          _searchAndChips(provider.tasks),
          if (filtered.isEmpty) ...[
            const SizedBox(height: 40),
            const EmptyView(
              message: 'No tasks match your filters.',
              icon: Icons.search_off_rounded,
            ),
          ] else
            ..._buildGrouped(filtered),
        ]);
    }
  }

  List<Widget> _buildGrouped(List<Task> tasks) {
    final groups = <_Bucket, List<Task>>{};
    for (final t in tasks) {
      groups.putIfAbsent(_bucketOf(t), () => []).add(t);
    }
    // Soonest first inside each group.
    for (final list in groups.values) {
      list.sort((a, b) {
        final ad = a.dueDate ?? DateTime(9999);
        final bd = b.dueDate ?? DateTime(9999);
        return ad.compareTo(bd);
      });
    }

    final children = <Widget>[];
    for (final bucket in _Bucket.values) {
      final list = groups[bucket];
      if (list == null || list.isEmpty) continue;
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 14, 0, 10),
          child: Text(
            _bucketTitles[bucket]!,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: bucket == _Bucket.overdue
                  ? AppColors.danger
                  : AppColors.muted,
            ),
          ),
        ),
      );
      for (final task in list) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TaskRow(
              task: task,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        TaskDetailsScreen(taskId: task.id, initialTask: task),
                  ),
                );
              },
            ),
          ),
        );
      }
    }

    return children;
  }
}
