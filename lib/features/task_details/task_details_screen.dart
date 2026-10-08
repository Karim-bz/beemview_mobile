import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/format.dart';
import '../../data/models/task.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/comment_composer_sheet.dart';
import '../../shared/widgets/priority_pill.dart';
import '../../shared/widgets/states.dart';
import '../../shared/widgets/status_picker_sheet.dart';
import '../../shared/widgets/status_pill.dart';
import '../auth/auth_provider.dart';
import '../project_tasks/project_tasks_provider.dart';
import '../projects/projects_provider.dart';
import 'task_details_provider.dart';
import 'widgets/task_assign_button.dart';
import 'widgets/task_assignee_chip.dart';
import 'widgets/task_comment_bar.dart';
import 'widgets/task_comment_tile.dart';
import 'widgets/task_info_tile.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key, required this.taskId, this.initialTask});

  final int taskId;
  final Task? initialTask;

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskDetailsProvider>().load(widget.taskId);
    });
  }

  // ---------------- Actions ----------------

  Future<void> _openStatusPicker(Task task) async {
    final selected = await showStatusPicker(context, current: task.status);
    if (selected == null || selected == task.status) return;
    if (!mounted) return;

    final author = context.read<AuthProvider>().user?.fullName;
    final outcome = await context.read<TaskDetailsProvider>().updateStatus(
      status: selected,
      authorName: author,
    );

    if (!mounted) return;
    // The status is saved in both of these cases: update the other screens.
    if (outcome == SubmitOutcome.fullSuccess ||
        outcome == SubmitOutcome.partialSuccess) {
      _syncLists(task);
    }
    _handleOutcome(outcome);
  }

  /// Keeps the project's task list, the progress bars, the Tasks tab and the
  /// Profile counters in step with a status change made here.
  void _syncLists(Task task) {
    context.read<ProjectsProvider>().refreshSilently();
    context.read<ProjectTasksProvider>().refreshSilently(
      projectId: task.projectId ?? task.project?.id,
    );
  }

  Future<void> _openCommentComposer() async {
    final text = await showCommentComposer(context);
    if (text == null || text.isEmpty) return;
    if (!mounted) return;

    final author = context.read<AuthProvider>().user?.fullName;
    final outcome = await context.read<TaskDetailsProvider>().addComment(
      content: text,
      authorName: author,
    );

    if (!mounted) return;
    _handleOutcome(outcome);
  }

  void _comingSoon(String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what — coming soon')));
  }

  void _handleOutcome(SubmitOutcome outcome) {
    final messenger = ScaffoldMessenger.of(context);
    switch (outcome) {
      case SubmitOutcome.fullSuccess:
        messenger.showSnackBar(const SnackBar(content: Text('Saved')));
        break;
      case SubmitOutcome.partialSuccess:
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Status saved, but the note failed to send.'),
            duration: Duration(seconds: 4),
          ),
        );
        break;
      case SubmitOutcome.failure:
        final msg =
            context.read<TaskDetailsProvider>().lastSubmitError ??
            'Something went wrong.';
        messenger.showSnackBar(SnackBar(content: Text(msg)));
        break;
      case SubmitOutcome.ignored:
        break;
    }
  }

  // ---------------- Build ----------------

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskDetailsProvider>();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: const [
                  SquareBackButton(),
                  SizedBox(width: 14),
                  Text(
                    'Task details',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody(provider)),
            if (provider.task != null)
              CommentBar(
                busy: provider.isSubmitting,
                onTap: _openCommentComposer,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TaskDetailsProvider provider) {
    switch (provider.status) {
      case DetailsStatus.idle:
      case DetailsStatus.loading:
        return const LoadingView(message: 'Loading task...');
      case DetailsStatus.error:
        return ErrorView(
          message: provider.error ?? 'Failed to load task.',
          onRetry: provider.reload,
        );
      case DetailsStatus.loaded:
        final task = provider.task;
        if (task == null) {
          return const EmptyView(message: 'Task not found.');
        }
        return _buildContent(provider, task);
    }
  }

  Widget _daysLeftChip(Task task) {
    final days = daysUntil(task.dueDate);
    if (days == null || isClosedStatus(task.status)) {
      return const SizedBox.shrink();
    }
    final overdue = days < 0;
    final color = overdue ? AppColors.danger : AppColors.orange;
    final text = overdue
        ? '${-days} day${days == -1 ? '' : 's'} overdue'
        : days == 0
        ? 'Due today'
        : '$days day${days == 1 ? '' : 's'} left';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: overdue ? color : const Color(0xFFE08A12),
        ),
      ),
    );
  }

  Widget _buildContent(TaskDetailsProvider provider, Task task) {
    final comments = provider.comments;
    final hasDescription = task.description?.isNotEmpty ?? false;

    return RefreshIndicator(
      onRefresh: provider.reload,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        children: [
          Text(
            task.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusPill(
                status: task.status,
                large: true,
                showChevron: true,
                onTap: provider.isSubmitting
                    ? null
                    : () => _openStatusPicker(task),
              ),
              if (task.priority != null)
                PriorityPill(priority: task.priority!, filled: true),
              _daysLeftChip(task),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            hasDescription ? task.description! : 'No description provided.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: hasDescription ? AppColors.muted : AppColors.hint,
            ),
          ),
          const SizedBox(height: 18),

          // ---- Info tiles ----
          Row(
            children: [
              Expanded(
                child: InfoTile(
                  icon: Icons.folder_outlined,
                  color: AppColors.teal,
                  label: 'Project',
                  value: task.project?.name ?? '—',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoTile(
                  icon: Icons.outlined_flag_rounded,
                  color: PriorityPill.colorFor(task.priority),
                  label: 'Priority',
                  value: task.priority == null
                      ? '—'
                      : PriorityPill.labelFor(task.priority!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InfoTile(
                  icon: Icons.calendar_today_outlined,
                  color: const Color(0xFF7B61FF),
                  label: 'Start',
                  value: fmtDate(task.startDate),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoTile(
                  icon: Icons.schedule_rounded,
                  color: AppColors.orange,
                  label: 'Due',
                  value: fmtDate(task.dueDate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ---- Assignees ----
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Assignees',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              for (final a in task.assignees) AssigneeChip(name: a.fullName),
              AssignButton(onTap: () => _comingSoon('Assigning people')),
            ],
          ),
          const SizedBox(height: 22),

          // ---- Comments ----
          Row(
            children: [
              const Text(
                'Comments',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (comments.isNotEmpty)
                Text(
                  '${comments.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (comments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No comments yet.',
                style: TextStyle(fontSize: 13.5, color: AppColors.hint),
              ),
            )
          else
            for (var i = 0; i < comments.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              CommentTile(comment: comments[i]),
            ],
        ],
      ),
    );
  }
}