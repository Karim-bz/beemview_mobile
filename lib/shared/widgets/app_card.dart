import 'package:flutter/material.dart';

import '../../core/colors.dart';

/// Borderless card with a soft shadow (surface color of the current theme).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppRadius.l,
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? context.palette.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Square white back button used in app bars.
class SquareBackButton extends StatelessWidget {
  const SquareBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.soft,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.arrow_back_rounded,
          size: 20,
          color: context.palette.ink,
        ),
        onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      ),
    );
  }
}

/// White search field with a leading icon.
class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.m),
        boxShadow: AppShadows.soft,
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search_rounded,
            color: context.palette.muted,
            size: 20,
          ),
          hintText: hint,
          hintStyle: TextStyle(color: context.palette.muted, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

/// Pill-shaped filter chip: "All 7", "● In progress 1".
class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.dotColor,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : context.palette.ink;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal : context.palette.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected ? AppShadows.glow(AppColors.teal) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white70 : context.palette.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
