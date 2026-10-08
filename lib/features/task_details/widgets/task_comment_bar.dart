import 'package:flutter/material.dart';

import '../../../core/colors.dart';

/// Tapping the field (or the send button) opens the comment composer sheet.
class CommentBar extends StatelessWidget {
  const CommentBar({super.key, required this.onTap, required this.busy});

  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: GestureDetector(
        onTap: busy ? null : onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 6, 6, 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Write a comment...',
                  style: TextStyle(
                    fontSize: 14.5,
                    color: AppColors.hint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: busy
                    ? const Padding(
                        padding: EdgeInsets.all(13),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
