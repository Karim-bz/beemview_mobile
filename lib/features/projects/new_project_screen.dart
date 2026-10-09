import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/colors.dart';
import '../../core/format.dart';
import '../../core/status_labels.dart';
import '../../data/models/new_project.dart';
import '../../data/models/project.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/comment_composer_sheet.dart' show GradientButton;
import '../../shared/widgets/form_parts.dart';
import '../../shared/widgets/status_picker_sheet.dart' show SheetHandle;
import 'projects_provider.dart';

/// Statuses a project can be created with, in display order.
const _creatableStatuses = <String>[
  'planning',
  'to_do',
  'in_progress',
  'on_hold',
];

const int _maxNameLength = 100;
const int _maxDescriptionLength = 1000;

/// Form to create a project (POST /projects).
/// Pops with `true` when the project was created.
class NewProjectScreen extends StatefulWidget {
  const NewProjectScreen({super.key});

  @override
  State<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitIdController = TextEditingController(); // fallback, see _unitField
  final _nameFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _unitIdFocus = FocusNode();

  OrganizationalUnit? _unit;
  String _status = 'planning';
  late DateTime _startDate;
  late DateTime _endDate;

  bool _unitError = false;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final today = dateOnly(DateTime.now());
    _startDate = today;
    _endDate = today.add(const Duration(days: 30));

    for (final f in [_nameFocus, _descriptionFocus, _unitIdFocus]) {
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
    _unitIdController.dispose();
    _nameFocus.dispose();
    _descriptionFocus.dispose();
    _unitIdFocus.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_submitting || _errorMessage == null) return;
    setState(() => _errorMessage = null);
  }

  // -------- Validation --------

  String? _validateName(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Project name is required';
    if (value.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  String? _validateUnitId(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Organizational unit ID is required';
    if (int.tryParse(value) == null) return 'Enter a valid number';
    return null;
  }

  bool get _datesValid => !_endDate.isBefore(_startDate);

  // -------- Pickers --------

  Future<void> _pickUnit(List<OrganizationalUnit> units) async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<OrganizationalUnit>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _UnitPickerSheet(units: units, selected: _unit),
    );
    if (picked != null) {
      setState(() {
        _unit = picked;
        _unitError = false;
        _errorMessage = null;
      });
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    FocusScope.of(context).unfocus();
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: isStart ? 'Start date' : 'End date',
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
        // Keep the original duration when the start moves past the end.
        if (_endDate.isBefore(d)) {
          _endDate = d.add(_endDate.difference(_startDate).abs());
        }
        _startDate = d;
      } else {
        _endDate = d;
      }
      _errorMessage = null;
    });
  }

  // -------- Submit --------

  Future<void> _submit({required bool hasKnownUnits}) async {
    if (_submitting) return;

    final formOk = _formKey.currentState?.validate() ?? false;
    final unitOk = !hasKnownUnits || _unit != null;
    setState(() => _unitError = !unitOk);
    if (!formOk || !unitOk || !_datesValid) return;

    final unitId = hasKnownUnits
        ? _unit!.id
        : int.parse(_unitIdController.text.trim());

    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await context.read<ProjectsProvider>().createProject(
        NewProject(
          name: _nameController.text.trim(),
          organizationalUnitId: unitId,
          description: _descriptionController.text.trim(),
          status: _status,
          startDate: _startDate,
          endDate: _endDate,
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
    final units = context.read<ProjectsProvider>().knownUnits;
    final hasUnits = units.isNotEmpty;

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
                  const Expanded(
                    child: Text(
                      'New project',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
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
                        const FormLabel('Project name'),
                        InputCard(
                          focused: _nameFocus.hasFocus,
                          child: TextFormField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            enabled: !_submitting,
                            validator: _validateName,
                            maxLength: _maxNameLength,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            style: _inputStyle,
                            decoration: _decoration(
                              hint: 'e.g. Website redesign',
                              icon: Icons.folder_outlined,
                              focused: _nameFocus.hasFocus,
                              hideCounter: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const FormLabel('Organizational unit'),
                        _unitField(units),
                        const SizedBox(height: 18),
                        const FormLabel('Status'),
                        _statusChips(),
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
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DateTile(
                                label: 'End',
                                date: _endDate,
                                error: !_datesValid,
                                onTap: _submitting
                                    ? null
                                    : () => _pickDate(isStart: false),
                              ),
                            ),
                          ],
                        ),
                        if (!_datesValid)
                          const FormFieldError('End date must be after start'),
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
                            style: _inputStyle.copyWith(height: 1.4),
                            decoration: _decoration(
                              hint: 'What is this project about?',
                              focused: _descriptionFocus.hasFocus,
                              hideCounter: true,
                              padding: const EdgeInsets.all(16),
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
                      label: 'Create project',
                      icon: Icons.check_rounded,
                      onPressed: () => _submit(hasKnownUnits: hasUnits),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // -------- Sections --------

  static const _inputStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  InputDecoration _decoration({
    required String hint,
    required bool focused,
    IconData? icon,
    bool hideCounter = false,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 17),
  }) {
    return InputDecoration(
      prefixIcon: icon == null
          ? null
          : Icon(
              icon,
              color: focused ? AppColors.teal : context.palette.muted,
              size: 20,
            ),
      hintText: hint,
      hintStyle: TextStyle(color: context.palette.muted, fontSize: 15),
      counterText: hideCounter ? '' : null,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      errorStyle: const TextStyle(
        color: AppColors.danger,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      contentPadding: padding,
    );
  }

  /// A picker when we know some units (from the loaded projects);
  /// otherwise a numeric ID field so the form is never blocked.
  Widget _unitField(List<OrganizationalUnit> units) {
    if (units.isEmpty) {
      return InputCard(
        focused: _unitIdFocus.hasFocus,
        child: TextFormField(
          controller: _unitIdController,
          focusNode: _unitIdFocus,
          enabled: !_submitting,
          validator: _validateUnitId,
          keyboardType: TextInputType.number,
          style: _inputStyle,
          decoration: _decoration(
            hint: 'Unit ID (e.g. 71)',
            icon: Icons.apartment_rounded,
            focused: _unitIdFocus.hasFocus,
          ),
        ),
      );
    }

    final unit = _unit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          onTap: _submitting ? null : () => _pickUnit(units),
          child: Row(
            children: [
              Icon(
                Icons.apartment_rounded,
                size: 20,
                color: unit == null ? context.palette.muted : AppColors.teal,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  unit?.name ?? 'Select a unit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: unit == null ? context.palette.muted : context.palette.ink,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: context.palette.hint,
              ),
            ],
          ),
        ),
        if (_unitError) const FormFieldError('Select an organizational unit'),
      ],
    );
  }

  Widget _statusChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final s in _creatableStatuses)
          _StatusChip(
            status: s,
            selected: s == _status,
            onTap: _submitting ? null : () => setState(() => _status = s),
          ),
      ],
    );
  }
}

// -------- Supporting widgets --------

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  final String status;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = StatusLabels.color(status);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : context.palette.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected ? AppShadows.glow(color) : AppShadows.soft,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: selected ? Colors.white : color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              StatusLabels.label(status),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : context.palette.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet listing the organizational units. Pops with the choice.
class _UnitPickerSheet extends StatelessWidget {
  const _UnitPickerSheet({required this.units, required this.selected});

  final List<OrganizationalUnit> units;
  final OrganizationalUnit? selected;

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
              'Organizational unit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final u in units)
                  _UnitTile(
                    unit: u,
                    selected: u.id == selected?.id,
                    onTap: () => Navigator.of(context).pop(u),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _UnitTile extends StatelessWidget {
  const _UnitTile({
    required this.unit,
    required this.selected,
    required this.onTap,
  });

  final OrganizationalUnit unit;
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: context.palette.tealTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.apartment_rounded,
                    size: 19,
                    color: AppColors.teal,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    unit.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? AppColors.tealDark : context.palette.ink,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_rounded,
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
