import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/status_labels.dart';
import '../../data/models/task.dart';
import '../../shared/widgets/states.dart';
import '../../shared/widgets/task_row.dart';
import 'project_tasks_provider.dart';

/// Statuses shown in the filter chip row (spec §8).
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

class ProjectTasksScreen extends StatefulWidget {
  const ProjectTasksScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  final int projectId;
  final String projectName;

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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectTasksProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 4,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.projectName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const Text(
              'Tasks',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildSearchRow(),
                  const SizedBox(height: 12),
                  _buildFilterChips(provider.tasks),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
          hintText: 'Search tasks...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFilterChips(List<Task> all) {
    final counts = <String?, int>{
      null: all.length,
      for (final s in _taskStatuses) s: all.where((t) => t.status == s).length,
    };

    final visible = <_FilterOption>[
      const _FilterOption(label: 'All', status: null),
      for (final s in _taskStatuses)
        if ((counts[s] ?? 0) > 0)
          _FilterOption(label: StatusLabels.label(s), status: s),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: visible.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = visible[index];
          final isSelected = _statusFilter == option.status;
          final count = counts[option.status] ?? 0;

          return ChoiceChip(
            label: Text('${option.label} ($count)'),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _statusFilter = option.status);
              }
            },
            selectedColor: AppColors.beemBlue,
            backgroundColor: const Color(0xFFF3F4F6),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: BorderSide.none,
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }

  Widget _buildBody(ProjectTasksProvider provider) {
    switch (provider.status) {
      case TasksStatus.idle:
      case TasksStatus.loading:
        return const LoadingView(message: 'Loading tasks...');
      case TasksStatus.error:
        return ErrorView(
          message: provider.error ?? 'Failed to load tasks.',
          onRetry: _refresh,
        );
      case TasksStatus.loaded:
        if (provider.tasks.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              children: const [
                SizedBox(height: 100),
                EmptyView(
                  message: 'This project has no tasks yet.',
                  icon: Icons.checklist_rounded,
                ),
              ],
            ),
          );
        }
        final filtered = _applyFilters(provider.tasks);
        if (filtered.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              children: const [
                SizedBox(height: 100),
                EmptyView(
                  message: 'No tasks match your filters.',
                  icon: Icons.search_off_rounded,
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final task = filtered[index];
              return TaskRow(
                task: task,
                onTap: () {
                  // Next step: navigate to TaskDetailsScreen.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Open "${task.name}" (next step)')),
                  );
                },
              );
            },
          ),
        );
    }
  }
}

class _FilterOption {
  const _FilterOption({required this.label, required this.status});
  final String label;
  final String? status;
}
