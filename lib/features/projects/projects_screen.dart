import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/status_labels.dart';
import '../../data/models/project.dart';
import '../../shared/widgets/states.dart';
import '../auth/auth_provider.dart';
import '../tasks/project_tasks_screen.dart';
import 'projects_provider.dart';

/// Raw API statuses shown as filter chips, in display order.
/// Labels are rendered via [StatusLabels.label].
const _projectStatuses = <String>[
  'planning',
  'to_do',
  'in_progress',
  'review',
  'on_hold',
  'done',
];

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  /// null = "All". Otherwise a raw API status string.
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Always reload on mount so a fresh login doesn't show stale data.
      context.read<ProjectsProvider>().load();
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

  Future<void> _refresh() => context.read<ProjectsProvider>().load();

  List<Project> _applyFilters(List<Project> all) {
    return all.where((p) {
      final matchesQuery =
          _query.isEmpty ||
          p.name.toLowerCase().contains(_query) ||
          (p.description ?? '').toLowerCase().contains(_query);

      final matchesStatus = _statusFilter == null || p.status == _statusFilter;

      return matchesQuery && matchesStatus;
    }).toList();
  }

  // -------- User helpers --------

  String _userLabel(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return '—';
    return user.fullName;
  }

  String _initialsFrom(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null || user.fullName.isEmpty) return '?';
    final parts = user.fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectsProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Projects',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Good morning, ${_userLabel(context)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.beemBlue.withValues(alpha: 0.15),
              child: Text(
                _initialsFrom(context),
                style: const TextStyle(
                  color: AppColors.beemBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
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
                  _buildFilterChips(provider.projects),
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
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                hintText: 'Search projects...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.tune_rounded,
              color: Colors.black54,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Advanced filters — coming soon')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(List<Project> all) {
    // Count projects per status; null key = "All".
    final counts = <String?, int>{
      null: all.length,
      for (final s in _projectStatuses)
        s: all.where((p) => p.status == s).length,
    };

    // Build chip descriptors, then keep only "All" + non-empty statuses.
    final chips = <_FilterOption>[
      const _FilterOption(label: 'All', status: null),
      for (final s in _projectStatuses)
        _FilterOption(label: StatusLabels.label(s), status: s),
    ];

    final visible = chips
        .where((c) => c.status == null || (counts[c.status] ?? 0) > 0)
        .toList();

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

  Widget _buildBody(ProjectsProvider provider) {
    switch (provider.status) {
      case ProjectsStatus.idle:
      case ProjectsStatus.loading:
        return const LoadingView(message: 'Loading projects...');
      case ProjectsStatus.error:
        return ErrorView(
          message: provider.error ?? 'Failed to load projects.',
          onRetry: _refresh,
        );
      case ProjectsStatus.loaded:
        if (provider.projects.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              children: const [
                SizedBox(height: 100),
                EmptyView(
                  message: 'No projects available yet.',
                  icon: Icons.folder_open_outlined,
                ),
              ],
            ),
          );
        }
        final filtered = _applyFilters(provider.projects);
        if (filtered.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              children: const [
                SizedBox(height: 100),
                EmptyView(
                  message: 'No projects match your filters.',
                  icon: Icons.search_off_rounded,
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          child: _buildList(provider, filtered),
        );
    }
  }

  Widget _buildList(ProjectsProvider provider, List<Project> items) {
    // Only show the "load more" footer when nothing is filtered — otherwise
    // pagination interacts oddly with client-side filtering.
    final canPaginate = _query.isEmpty && _statusFilter == null;
    final showFooter =
        canPaginate && (provider.hasMore || provider.isLoadingMore);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: items.length + (showFooter ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == items.length) return _buildFooter(provider);
        return _ProjectCard(project: items[index]);
      },
    );
  }

  Widget _buildFooter(ProjectsProvider provider) {
    if (provider.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: OutlinedButton(
          onPressed: () => context.read<ProjectsProvider>().loadMore(),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.beemBlue,
            side: const BorderSide(color: AppColors.beemBlue),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Load more'),
        ),
      ),
    );
  }
}

// -------- Supporting widgets --------

class _FilterOption {
  const _FilterOption({required this.label, required this.status});

  final String label;

  /// Raw API status this chip filters by.
  /// `null` means "All" — no filtering.
  final String? status;
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProjectTasksScreen(
              projectId: project.id,
              projectName: project.name,
            ),
          ),
        );
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(content: Text('Open "${project.name}"')));
      },
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.beemBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.folder_rounded,
                    color: AppColors.beemBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        project.organizationalUnit?.name ?? "-",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
              ],
            ),
            if (project.description != null &&
                project.description!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                project.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _StatusPill(status: project.status),
                const Spacer(),
                const Icon(
                  Icons.checklist_rounded,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${project.taskCount} task${project.taskCount == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    if (status == null || status!.isEmpty) {
      return const SizedBox.shrink();
    }
    final color = StatusLabels.color(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        StatusLabels.label(status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
