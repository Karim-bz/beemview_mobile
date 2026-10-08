import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/format.dart';
import '../../core/status_labels.dart';
import '../../data/models/project.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/initials_avatar.dart';
import '../../shared/widgets/states.dart';
import '../auth/auth_provider.dart';
import '../shell/main_shell.dart';
import '../project_tasks/project_tasks_screen.dart';
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

  void _comingSoon(String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what — coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectsProvider>();
    final user = context.watch<AuthProvider>().user;
    final name = user?.fullName ?? '';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      floatingActionButton: _AddButton(onTap: () => _comingSoon('New project')),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _Header(
                greeting: name.isEmpty
                    ? greeting()
                    : '${greeting()}, ${firstName(name)} 👋',
                initials: name.isEmpty ? '?' : InitialsAvatar.initialsOf(name),
                onAvatarTap: () => shellIndex.value = 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  _buildSearchRow(),
                  const SizedBox(height: 14),
                  _buildFilterChips(provider.projects),
                ],
              ),
            ),
            const SizedBox(height: 14),
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
          child: SearchField(
            controller: _searchController,
            hint: 'Search projects...',
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.m),
            boxShadow: AppShadows.soft,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.tune_rounded,
              color: AppColors.ink,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            onPressed: () => _comingSoon('Advanced filters'),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(List<Project> all) {
    final counts = <String?, int>{
      null: all.length,
      for (final s in _projectStatuses)
        s: all.where((p) => p.status == s).length,
    };

    final options = <String?>[
      null,
      for (final s in _projectStatuses)
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
            label: status == null ? 'All' : StatusLabels.label(status),
            count: counts[status] ?? 0,
            selected: _statusFilter == status,
            onTap: () => setState(() => _statusFilter = status),
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
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
      itemCount: items.length + (showFooter ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 14),
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
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: TextButton(
          onPressed: () => context.read<ProjectsProvider>().loadMore(),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.teal,
            backgroundColor: AppColors.tealTint,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.m),
            ),
          ),
          child: const Text(
            'Load more',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

// -------- Supporting widgets --------

class _Header extends StatelessWidget {
  const _Header({
    required this.greeting,
    required this.initials,
    required this.onAvatarTap,
  });

  final String greeting;
  final String initials;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Projects',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.tealTint, width: 3),
            ),
            child: CircleAvatar(
              backgroundColor: AppColors.tealTint,
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColors.teal,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFB04D), AppColors.orange],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.glow(AppColors.orange),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final tasks = project.taskCount;
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProjectTasksScreen(
              projectId: project.id,
              project: project,
              projectName: project.name,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: InitialsAvatar.colorFor(project.name),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  InitialsAvatar.initialsOf(project.name, twoLetters: true),
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
                      project.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      project.organizationalUnit?.name ?? '-',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.hint,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                tasks == 0
                    ? 'No tasks yet'
                    : '${project.doneCount} of $tasks tasks done',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: tasks == 0 ? FontWeight.w500 : FontWeight.w700,
                  color: tasks == 0 ? AppColors.muted : AppColors.ink,
                ),
              ),
              const Spacer(),
              AvatarStack(
                names: project.assigneeNames,
                max: 2,
                total: project.assigneeNames.length,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
