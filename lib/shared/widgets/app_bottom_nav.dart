import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../l10n/app_strings.dart';

class NavTab {
  NavTab(this.labelOf, this.icon, this.activeIcon);
  final String Function(AppStrings) labelOf;
  final IconData icon;
  final IconData activeIcon;
}

final kNavTabs = [
  NavTab((s) => s.navProjects, Icons.folder_outlined, Icons.folder_rounded),
  NavTab(
    (s) => s.navTasks,
    Icons.check_box_outlined,
    Icons.check_box_rounded,
  ),
  NavTab(
    (s) => s.navNotifications,
    Icons.notifications_none_rounded,
    Icons.notifications_rounded,
  ),
  NavTab(
    (s) => s.navProfile,
    Icons.person_outline_rounded,
    Icons.person_rounded,
  ),
];

/// Bottom navigation with a tinted pill behind the active icon.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showNotificationDot = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool showNotificationDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: context.palette.ink.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
          child: Row(
            children: [
              for (var i = 0; i < kNavTabs.length; i++)
                Expanded(
                  child: _NavItem(
                    tab: kNavTabs[i],
                    selected: i == currentIndex,
                    dot: i == 2 && showNotificationDot,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.dot,
    required this.onTap,
  });

  final NavTab tab;
  final bool selected;
  final bool dot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.teal : context.palette.muted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 32,
            decoration: BoxDecoration(
              color: selected ? context.palette.tealTint : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  selected ? tab.activeIcon : tab.icon,
                  size: 22,
                  color: color,
                ),
                if (dot)
                  PositionedDirectional(
                    top: 5,
                    end: 15,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.palette.surface, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tab.labelOf(context.l10n),
            maxLines: 1,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
