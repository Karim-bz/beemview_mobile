import 'package:flutter/material.dart';

import '../../shared/widgets/app_bottom_nav.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../projects/projects_screen.dart';
import '../tasks/tasks_screen.dart';

/// Lets any screen switch the active bottom-nav tab.
final ValueNotifier<int> shellIndex = ValueNotifier<int>(0);

/// Shared tap handling for the bottom nav (the Tasks tab is a placeholder).
void onShellTabTap(BuildContext context, int index) {
  shellIndex.value = index;
}

/// Root screen for authenticated users.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    shellIndex.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: shellIndex,
      builder: (context, index, _) => Scaffold(
        body: IndexedStack(
          index: index,
          children: const [
            ProjectsScreen(),
            TasksScreen(),
            NotificationsScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: index,
          onTap: (i) => onShellTabTap(context, i),
        ),
      ),
    );
  }
}
