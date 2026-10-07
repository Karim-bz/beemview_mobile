import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../data/models/comment.dart';
import '../../data/models/task.dart';
import '../../shared/widgets/comment_composer_sheet.dart';
import '../../shared/widgets/initials_avatar.dart';
import '../../shared/widgets/priority_pill.dart';
import '../../shared/widgets/states.dart';
import '../../shared/widgets/status_picker_sheet.dart';
import '../../shared/widgets/status_pill.dart';
import '../auth/auth_provider.dart';
import 'task_details_provider.dart';

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
    _handleOutcome(outcome);
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
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Task Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(child: _buildBody(provider)),
      bottomNavigationBar: provider.task == null
          ? null
          : _TaskActionBar(
              busy: provider.isSubmitting,
              onChangeStatus: () => _openStatusPicker(provider.task!),
              onAddComment: _openCommentComposer,
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

  Widget _buildContent(TaskDetailsProvider provider, Task task) {
    final comments = provider.comments;

    return RefreshIndicator(
      onRefresh: provider.reload,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // ---- Title block ----
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEEF1F5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    StatusPill(status: task.status),
                    const SizedBox(width: 8),
                    if (task.priority != null)
                      PriorityPill(priority: task.priority!),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ---- Description + meta ----
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel('Description'),
                const SizedBox(height: 6),
                Text(
                  (task.description?.isNotEmpty ?? false)
                      ? task.description!
                      : 'No description provided.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: (task.description?.isNotEmpty ?? false)
                        ? Colors.black87
                        : Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                const _Divider(),
                const SizedBox(height: 12),
                _MetaRow(
                  icon: Icons.flag_outlined,
                  label: 'Priority',
                  value: task.priority?.toUpperCase() ?? '—',
                ),
                const SizedBox(height: 10),
                _MetaRow(
                  icon: Icons.folder_outlined,
                  label: 'Project',
                  value: task.project?.name ?? '—',
                ),
                const SizedBox(height: 10),
                _MetaRow(
                  icon: Icons.event_outlined,
                  label: 'Start',
                  value: _fmtDate(task.startDate),
                ),
                const SizedBox(height: 10),
                _MetaRow(
                  icon: Icons.event_available_outlined,
                  label: 'Due',
                  value: _fmtDate(task.dueDate),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ---- Assignees ----
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel('Assignees'),
                const SizedBox(height: 10),
                if (task.assignees.isEmpty)
                  const Text(
                    'No assignees',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: task.assignees
                        .map((a) => _AssigneeChip(name: a.fullName))
                        .toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ---- Comments ----
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _SectionLabel('Comments'),
                    const Spacer(),
                    if (comments.isNotEmpty)
                      Text(
                        '${comments.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (comments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No comments yet.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  )
                else
                  for (var i = 0; i < comments.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _CommentTile(comment: comments[i]),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime? d) {
    if (d == null) return '—';
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

// ---------------- Bottom action bar ----------------

/// Rendered as a persistent bottom bar so it stays visible while the
/// user scrolls. Uses a floating-look container with soft shadow.
class _TaskActionBar extends StatelessWidget {
  const _TaskActionBar({
    required this.onChangeStatus,
    required this.onAddComment,
    required this.busy,
  });

  final VoidCallback? onChangeStatus;
  final VoidCallback? onAddComment;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: busy ? null : onChangeStatus,
                icon: const Icon(Icons.sync_alt_rounded, size: 18),
                label: const Text('Change status'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.beemBlue,
                  side: const BorderSide(color: AppColors.beemBlue),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: busy ? null : onAddComment,
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text('Add comment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.beemBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEF1F5)),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: Colors.grey,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: const Color(0xFFEEF1F5));
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey),
        const SizedBox(width: 8),
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _AssigneeChip extends StatelessWidget {
  const _AssigneeChip({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEF1F5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InitialsAvatar(name: name, radius: 10),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});
  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InitialsAvatar(name: comment.authorName, radius: 14),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.authorName.isEmpty
                            ? 'Unknown'
                            : comment.authorName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (comment.createdAt != null)
                      Text(
                        _relTime(comment.createdAt!),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _relTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
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
    return '${months[dt.month - 1]} ${dt.day}';
  }
}
