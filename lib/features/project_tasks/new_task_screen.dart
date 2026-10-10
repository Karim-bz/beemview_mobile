import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/colors.dart';
import '../../core/format.dart';
import '../../core/status_labels.dart';
import '../../data/models/new_task.dart';
import '../../data/models/task.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/comment_composer_sheet.dart' show GradientButton;
import '../../shared/widgets/form_parts.dart';
import '../../shared/widgets/initials_avatar.dart';
import '../../shared/widgets/priority_pill.dart';
import '../../shared/widgets/status_picker_sheet.dart' show SheetHandle;
import '../auth/auth_provider.dart';
import '../task_details/widgets/task_assign_button.dart';
import 'project_tasks_provider.dart';

/// Statuses a task can be created with, in display order.
const _creatableStatuses = <String>['to_do', 'in_progress', 'on_hold'];

/// API priority values, lowest first.
const _priorities = <String>['low', 'medium', 'high', 'urgent'];

const int _maxDescriptionLength = 1000;

/// Form to create a task in a project (POST /tasks).
/// Pops with `true` when the task was created.
class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  final int projectId;
  final String projectName;

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  String _status = 'to_do';
  String _priority = 'medium';
  DateTime? _startDate;
  DateTime? _dueDate;
  bool _isPrivate = false;
  List<Assignee> _assignees = [];

  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startDate = dateOnly(DateTime.now());
    for (final f in [_nameFocus, _descriptionFocus]) {
      f.addListener(() => setState(() {}));
    }
    _nameController.addListener(_clearError);
    _descriptionController.addListener(() {
      _clearError();
      setState(() {}); // refresh the character counter
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_submitting || _errorMessage == null) return;
    setState(() => _errorMessage = null);
  }

  // -------- Validation --------

  String? _validateName(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Task name is required';
    if (value.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  bool get _datesValid =>
      _startDate == null ||
      _dueDate == null ||
      !_dueDate!.isBefore(_startDate!);

  // -------- Assignees --------

  /// People we can offer: you + everyone already assigned in this project.
  /// (No users endpoint is wired yet.)
  List<Assignee> _candidates() {
    final byId = <int, Assignee>{};
    final me = context.read<AuthProvider>().user;
    if (me != null) {
      byId[me.id] = Assignee(id: me.id, fullName: me.fullName);
    }
    for (final a in context.read<ProjectTasksProvider>().knownAssignees) {
      byId.putIfAbsent(a.id, () => a);
    }
    return byId.values.toList()..sort(
      (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
    );
  }

  Future<void> _pickAssignees() async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<List<Assignee>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AssigneePickerSheet(
        candidates: _candidates(),
        selectedIds: _assignees.map((a) => a.id).toSet(),
      ),
    );
    if (picked != null) setState(() => _assignees = picked);
  }

  // -------- Dates --------

  Future<void> _pickDate({required bool isStart}) async {
    FocusScope.of(context).unfocus();
    final current = isStart ? _startDate : _dueDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? _startDate ?? dateOnly(DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: isStart ? 'Start date' : 'Due date',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme
              .copyWith(primary: AppColors.teal),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      final d = dateOnly(picked);
      if (isStart) {
        // Keep the same gap when the start moves past an existing due date.
        if (_dueDate != null && _dueDate!.isBefore(d)) {
          final gap = _startDate == null
              ? Duration.zero
              : _dueDate!.difference(_startDate!).abs();
          _dueDate = d.add(gap);
        }
        _startDate = d;
      } else {
        _dueDate = d;
      }
      _errorMessage = null;
    });
  }

  // -------- Submit --------

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false) || !_datesValid) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await context.read<ProjectTasksProvider>().createTask(
        NewTask(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          status: _status,
          priority: _priority,
          startDate: _startDate,
          dueDate: _dueDate,
          projectId: widget.projectId,
          isPrivate: _isPrivate,
          assigneeIds: _assignees.map((a) => a.id).toList(),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = e.message;
      });
    }
  }

  // -------- Build --------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  SquareBackButton(
                    onPressed: () {
                      if (!_submitting) Navigator.of(context).maybePop();
                    },
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'New task',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          widget.projectName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: context.palette.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_errorMessage != null) ...[
                          FormErrorBanner(message: _errorMessage!),
                          const SizedBox(height: 16),
                        ],
                        const FormLabel('Task name'),
                        InputCard(
                          focused: _nameFocus.hasFocus,
                          child: TextFormField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            enabled: !_submitting,
                            validator: _validateName,
                            maxLength: 150,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            style: kInputStyle,
                            decoration: formInputDecoration(
                              hint: 'e.g. Create employee module',
                              icon: Icons.task_alt_rounded,
                              focused: _nameFocus.hasFocus,
                              context: context,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const FormLabel('Status'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final s in _creatableStatuses)
                              ChoicePill(
                                label: StatusLabels.label(s),
                                color: StatusLabels.color(s),
                                selected: s == _status,
                                onTap: _submitting
                                    ? null
                                    : () => setState(() => _status = s),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const FormLabel('Priority'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final p in _priorities)
                              ChoicePill(
                                label: PriorityPill.labelFor(p),
                                color: PriorityPill.colorFor(p),
                                icon: Icons.outlined_flag_rounded,
                                selected: p == _priority,
                                onTap: _submitting
                                    ? null
                                    : () => setState(() => _priority = p),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const FormLabel('Timeline'),
                        Row(
                          children: [
                            Expanded(
                              child: DateTile(
                                label: 'Start',
                                date: _startDate,
                                onTap: _submitting
                                    ? null
                                    : () => _pickDate(isStart: true),
                                onClear: _submitting
                                    ? null
                                    : () => setState(() => _startDate = null),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DateTile(
                                label: 'Due',
                                date: _dueDate,
                                error: !_datesValid,
                                onTap: _submitting
                                    ? null
                                    : () => _pickDate(isStart: false),
                                onClear: _submitting
                                    ? null
                                    : () => setState(() => _dueDate = null),
                              ),
                            ),
                          ],
                        ),
                        if (!_datesValid)
                          const FormFieldError('Due date must be after start'),
                        const SizedBox(height: 18),
                        const FormLabel('Assignees'),
                        _assigneesSection(),
                        const SizedBox(height: 18),
                        const FormLabel('Description (optional)'),
                        InputCard(
                          focused: _descriptionFocus.hasFocus,
                          child: TextFormField(
                            controller: _descriptionController,
                            focusNode: _descriptionFocus,
                            enabled: !_submitting,
                            minLines: 4,
                            maxLines: 8,
                            maxLength: _maxDescriptionLength,
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.multiline,
                            style: kInputStyle.copyWith(height: 1.4),
                            decoration: formInputDecoration(
                              hint: 'What needs to be done?',
                              focused: _descriptionFocus.hasFocus,
                              padding: const EdgeInsets.all(16),
                              context: context,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6, right: 4),
                            child: Text(
                              '${_descriptionController.text.length} / $_maxDescriptionLength',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: context.palette.hint,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _privateSwitch(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: _submitting
                  ? const SizedBox(
                      height: 52,
                      child: Center(
                        child: SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                      ),
                    )
                  : GradientButton(
                      label: 'Create task',
                      icon: Icons.check_rounded,
                      onPressed: _submit,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // -------- Sections --------

  Widget _assigneesSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final a in _assignees)
          _RemovableAssignee(
            name: a.fullName,
            onRemove: _submitting
                ? null
                : () => setState(() => _assignees.remove(a)),
          ),
        AssignButton(onTap: _submitting ? () {} : _pickAssignees),
      ],
    );
  }

  Widget _privateSwitch() {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            _isPrivate ? Icons.lock_rounded : Icons.lock_open_rounded,
            size: 20,
            color: _isPrivate ? AppColors.teal : context.palette.muted,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Private task',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          Switch(
            value: _isPrivate,
            activeTrackColor: AppColors.teal,
            onChanged: _submitting
                ? null
                : (v) => setState(() => _isPrivate = v),
          ),
        ],
      ),
    );
  }
}

// -------- Supporting widgets --------

/// Assignee chip with a small "x" to remove it.
class _RemovableAssignee extends StatelessWidget {
  const _RemovableAssignee({required this.name, required this.onRemove});

  final String name;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 6, 5),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InitialsAvatar(name: name, radius: 11),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                size: 15,
                color: context.palette.hint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Multi-select sheet. Pops with the chosen assignees on "Done".
class _AssigneePickerSheet extends StatefulWidget {
  const _AssigneePickerSheet({
    required this.candidates,
    required this.selectedIds,
  });

  final List<Assignee> candidates;
  final Set<int> selectedIds;

  @override
  State<_AssigneePickerSheet> createState() => _AssigneePickerSheetState();
}

class _AssigneePickerSheetState extends State<_AssigneePickerSheet> {
  late final Set<int> _selected = {...widget.selectedIds};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const SheetHandle(),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Assign people',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final a in widget.candidates)
                  _PersonTile(
                    name: a.fullName,
                    selected: _selected.contains(a.id),
                    onTap: () => setState(() {
                      if (!_selected.remove(a.id)) _selected.add(a.id);
                    }),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: GradientButton(
              label: _selected.isEmpty
                  ? 'Done'
                  : 'Done (${_selected.length} selected)',
              onPressed: () => Navigator.of(context).pop([
                for (final a in widget.candidates)
                  if (_selected.contains(a.id)) a,
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? context.palette.tealTint : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.m),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.m),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                InitialsAvatar(name: name, radius: 17),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected
                          ? AppColors.tealDark
                          : context.palette.ink,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.teal,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
