import 'package:flutter/material.dart';

import '../../../core/colors.dart';
import '../../../l10n/app_strings.dart';

/// Shown when a status was saved but its optional note failed to post.
/// Offers to retry the comment only, or to discard the note.
class PendingNoteBanner extends StatelessWidget {
  const PendingNoteBanner({
    super.key,
    required this.note,
    required this.busy,
    required this.maybeSent,
    required this.onRetry,
    required this.onDiscard,
  });

  final String note;

  /// True while a submission is running (disables both actions).
  final bool busy;

  /// True when the failure was a network/timeout error, so the server may
  /// have received the comment anyway.
  final bool maybeSent;

  final VoidCallback onRetry;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: context.palette.ink),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.noteNotSentTitle,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5, height: 1.4),
          ),
          if (maybeSent) ...[
            const SizedBox(height: 8),
            Text(
              context.l10n.noteMaybeDelivered,
              style: TextStyle(fontSize: 12.5, color: context.palette.muted),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: busy ? null : onDiscard,
                child: Text(context.l10n.discardNote),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: busy ? null : onRetry,
                style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
                child: Text(context.l10n.retryNote),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
