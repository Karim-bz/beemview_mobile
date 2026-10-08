import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/format.dart';
import 'app_card.dart';

/// Text style used inside form fields.
const kInputStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w500);

/// Borderless decoration; the border/shadow comes from [InputCard].
InputDecoration formInputDecoration({
  required String hint,
  required bool focused,
  IconData? icon,
  EdgeInsets padding = const EdgeInsets.symmetric(vertical: 17),
}) {
  return InputDecoration(
    prefixIcon: icon == null
        ? null
        : Icon(
            icon,
            color: focused ? AppColors.teal : AppColors.muted,
            size: 20,
          ),
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.muted, fontSize: 15),
    counterText: '',
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

class FormLabel extends StatelessWidget {
  const FormLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
        ),
      ),
    );
  }
}

class FormFieldError extends StatelessWidget {
  const FormFieldError(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, top: 6),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.danger,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// White rounded card that gets a teal outline while focused
/// (same look as the login fields).
class InputCard extends StatelessWidget {
  const InputCard({super.key, required this.child, required this.focused});

  final Widget child;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(
          color: focused ? AppColors.teal : Colors.transparent,
          width: 2,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: child,
    );
  }
}

class FormErrorBanner extends StatelessWidget {
  const FormErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerTint,
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.danger,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.danger,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tappable date card. A null [date] shows "Not set"; pass [onClear]
/// to let the user remove an optional date.
class DateTile extends StatelessWidget {
  const DateTile({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
    this.onClear,
    this.error = false,
  });

  final String label;
  final DateTime? date;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(
          color: error ? AppColors.danger : Colors.transparent,
          width: 2,
        ),
      ),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: date == null ? AppColors.muted : AppColors.teal,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date == null ? 'Not set' : fmtDate(date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: date == null ? AppColors.muted : AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            if (date != null && onClear != null)
              GestureDetector(
                onTap: onClear,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.hint,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Single-select pill (status, priority...). Fills with [color] when selected.
class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  /// Optional leading icon; a colored dot is shown when null.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.ink;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected ? AppShadows.glow(color) : AppShadows.soft,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(icon, size: 15, color: selected ? Colors.white : color)
            else
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
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
