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
import '../../shared/widgets/status_update_sheet.dart';
import '../auth/auth_provider.dart';
import '../project_tasks/project_tasks_provider.dart';
import '../projects/projects_provider.dart';
import 'task_details_provider.dart';
import 'widgets/pending_note_banner.dart';
import 'widgets/task_assign_button.dart';
import 'widgets/task_assignee_chip.dart';
import 'widgets/task_comment_bar.dart';
import 'widgets/task_comment_tile.dart';
import 'widgets/task_info_tile.dart';
import '../../l10n/app_strings.dart';

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

    // Second step: confirm and add the optional note.
    final request = await showStatusUpdateSheet(
      context,
      current: task.status,
      selected: selected,
    );
    if (request == null) return;
    if (!mounted) return;

    final author = context.read<AuthProvider>().user?.fullName;
    final outcome = await context.read<TaskDetailsProvider>().updateStatus(
      status: request.status,
      note: request.note,
      authorName: author ?? context.l10n.you,
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
      authorName: author ?? context.l10n.you,
    );

    if (!mounted) return;
    _handleOutcome(outcome);
  }

  /// Retries only the note that failed after the status was saved.
  Future<void> _retryPendingNote() async {
    final author = context.read<AuthProvider>().user?.fullName;
    final outcome = await context
        .read<TaskDetailsProvider>()
        .retryPendingComment(authorName: author ?? context.l10n.you);
    if (!mounted) return;
    _handleOutcome(outcome, isRetry: true);
  }

  void _comingSoon(String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.comingSoon(what))));
  }

  void _handleOutcome(SubmitOutcome outcome, {bool isRetry = false}) {
    final messenger = ScaffoldMessenger.of(context);
    switch (outcome) {
      case SubmitOutcome.fullSuccess:
        messenger.showSnackBar(SnackBar(content: Text(context.l10n.saved)));
        break;
      case SubmitOutcome.partialSuccess:
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              isRetry
                  ? context.l10n.noteNotSentYet
                  : context.l10n.statusSavedNoteFailed,
            ),
            duration: const Duration(seconds: 4),
          ),
        );
        break;
      case SubmitOutcome.failure:
        final msg =
            context.read<TaskDetailsProvider>().lastSubmitError ??
            context.l10n.somethingWentWrong;
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
      backgroundColor: context.palette.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  SquareBackButton(),
                  SizedBox(width: 14),
                  Text(
                    context.l10n.taskDetails,
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
        return LoadingView(message: context.l10n.loadingTask);
      case DetailsStatus.error:
        return ErrorView(
          message: provider.error ?? context.l10n.failedLoadTask,
          onRetry: provider.reload,
        );
      case DetailsStatus.loaded:
        final task = provider.task;
        if (task == null) {
          return EmptyView(message: context.l10n.taskNotFound);
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
        ? context.l10n.daysOverdue(-days)
        : days == 0
        ? context.l10n.dueToday
        : context.l10n.daysLeft(days);
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
          if (provider.pendingNote != null) ...[
            PendingNoteBanner(
              note: provider.pendingNote!,
              busy: provider.isSubmitting,
              maybeSent: provider.pendingNoteMaybeSent,
              onRetry: _retryPendingNote,
              onDiscard: provider.discardPendingNote,
            ),
            const SizedBox(height: 14),
          ],
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
            hasDescription ? task.description! : context.l10n.noDescription,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: hasDescription ? context.palette.muted : context.palette.hint,
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
                  label: context.l10n.project,
                  value: task.project?.name ?? '—',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoTile(
                  icon: Icons.outlined_flag_rounded,
                  color: PriorityPill.colorFor(task.priority),
                  label: context.l10n.priority,
                  value: task.priority == null
                      ? '—'
                      : PriorityPill.labelFor(context.l10n, task.priority!),
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
                  label: context.l10n.start,
                  value: fmtDate(context.l10n, task.startDate),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoTile(
                  icon: Icons.schedule_rounded,
                  color: AppColors.orange,
                  label: context.l10n.due,
                  value: fmtDate(context.l10n, task.dueDate),
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
              Text(
                context.l10n.assignees,
                style: TextStyle(
                  fontSize: 13,
                  color: context.palette.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              for (final a in task.assignees) AssigneeChip(name: a.fullName),
              AssignButton(onTap: () => _comingSoon(context.l10n.assigningPeople)),
            ],
          ),
          const SizedBox(height: 22),

          // ---- Comments ----
          Row(
            children: [
              Text(
                context.l10n.comments,
                style: TextStyle(
                  fontSize: 13,
                  color: context.palette.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (comments.isNotEmpty)
                Text(
                  '${comments.length}',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.palette.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (comments.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                context.l10n.noCommentsYet,
                style: TextStyle(fontSize: 13.5, color: context.palette.hint),
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