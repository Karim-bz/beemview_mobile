import 'package:flutter/material.dart';

import '../../core/colors.dart';
import 'status_picker_sheet.dart' show SheetHandle;

const int kMaxCommentLength = 500;

/// Shows a modal bottom sheet for composing a comment.
/// Returns the trimmed text, or null if the user cancelled.
Future<String?> showCommentComposer(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _CommentComposerSheet(),
  );
}

class _CommentComposerSheet extends StatefulWidget {
  const _CommentComposerSheet();

  @override
  State<_CommentComposerSheet> createState() => _CommentComposerSheetState();
}

class _CommentComposerSheetState extends State<_CommentComposerSheet> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final canSend = _controller.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHandle(),
              const SizedBox(height: 16),
              const Text(
                'Add a comment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                autofocus: true,
                maxLines: 6,
                minLines: 5,
                maxLength: kMaxCommentLength,
                buildCounter:
                    (
                      context, {
                      required currentLength,
                      required isFocused,
                      required maxLength,
                    }) => null,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(fontSize: 15, height: 1.4),
                decoration: InputDecoration(
                  hintText: 'Write your comment...',
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: context.palette.hint,
                  ),
                  filled: true,
                  fillColor: context.palette.surface,
                  contentPadding: const EdgeInsets.all(16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.l),
                    borderSide: BorderSide(color: context.palette.track),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.l),
                    borderSide: const BorderSide(
                      color: AppColors.teal,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_controller.text.length} / $kMaxCommentLength',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: context.palette.hint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.palette.ink,
                          backgroundColor: context.palette.surface,
                          side: BorderSide(color: context.palette.track),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.m),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 6,
                    child: GradientButton(
                      label: 'Send',
                      icon: Icons.send_rounded,
                      onPressed: canSend ? _submit : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Teal gradient call-to-action button with a soft glow.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 52,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(AppRadius.m),
          boxShadow: enabled ? AppShadows.glow(AppColors.teal) : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.m),
            onTap: onPressed,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
