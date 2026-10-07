import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../projects/projects_screen.dart';

/// Root screen for authenticated users.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = [
    _TabSpec(
      label: 'Projects',
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder_rounded,
    ),
    _TabSpec(
      label: 'Tasks',
      icon: Icons.check_box_outlined,
      activeIcon: Icons.check_box_rounded,
    ),
    _TabSpec(
      label: 'Notifications',
      icon: Icons.notifications_none_rounded,
      activeIcon: Icons.notifications_rounded,
    ),
    _TabSpec(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  void _onTap(int index) {
    // Only Projects and Profile are wired. Others are placeholders.
    if (index != 1) {
      setState(() => _index = index);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_tabs[index].label} — coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _index,
        children: const [
          ProjectsScreen(),
          SizedBox.shrink(), // Tasks placeholder (unused)
          NotificationsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: _onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.beemBlue,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: _tabs
              .map(
                (t) => BottomNavigationBarItem(
                  icon: Icon(t.icon),
                  activeIcon: Icon(t.activeIcon),
                  label: t.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
