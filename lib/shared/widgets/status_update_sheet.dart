import 'package:flutter/material.dart';

import '../../core/colors.dart';
import 'comment_composer_sheet.dart' show GradientButton, kMaxCommentLength;
import 'status_picker_sheet.dart' show SheetHandle;
import 'status_pill.dart';

/// What the user confirmed in the status update sheet.
class StatusUpdateRequest {
  const StatusUpdateRequest({required this.status, this.note});

  /// Raw API value (e.g. `in_progress`).
  final String status;

  /// Trimmed optional note, or null when left empty.
  final String? note;
}

/// Confirmation step shown after a status was picked: lets the user add an
/// optional note, which is later posted as a separate comment.
/// Returns null if the user cancelled.
Future<StatusUpdateRequest?> showStatusUpdateSheet(
  BuildContext context, {
  required String? current,
  required String selected,
}) {
  return showModalBottomSheet<StatusUpdateRequest>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _StatusUpdateSheet(current: current, selected: selected),
  );
}

class _StatusUpdateSheet extends StatefulWidget {
  const _StatusUpdateSheet({required this.current, required this.selected});

  final String? current;
  final String selected;

  @override
  State<_StatusUpdateSheet> createState() => _StatusUpdateSheetState();
}

class _StatusUpdateSheetState extends State<_StatusUpdateSheet> {
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
    final note = _controller.text.trim();
    Navigator.of(context).pop(
      StatusUpdateRequest(
        status: widget.selected,
        note: note.isEmpty ? null : note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
                'Update status',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  StatusPill(status: widget.current),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: AppColors.muted,
                    ),
                  ),
                  StatusPill(status: widget.selected, large: true),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _controller,
                maxLines: 5,
                minLines: 3,
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
                  hintText: 'Add a note (optional). Posted as a comment.',
                  hintStyle: const TextStyle(
                    fontSize: 15,
                    color: AppColors.hint,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.l),
                    borderSide: const BorderSide(color: AppColors.track),
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
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.hint,
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
                          foregroundColor: AppColors.ink,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.track),
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
                      label: 'Save status',
                      icon: Icons.check_rounded,
                      onPressed: _submit,
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
