import 'package:flutter/material.dart';

import '../../../core/colors.dart';
import '../../../core/format.dart';
import '../../../data/models/comment.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/initials_avatar.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({super.key, required this.comment});
  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InitialsAvatar(name: comment.authorName, radius: 17),
        const SizedBox(width: 10),
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            radius: AppRadius.m,
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
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (comment.createdAt != null)
                      Text(
                        relTime(comment.createdAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: context.palette.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
