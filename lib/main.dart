import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/connectivity_service.dart';
import 'core/secure_storage.dart';
import 'core/theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/project_repository.dart';
import 'data/repositories/task_repository.dart';
import 'features/appearance/theme_provider.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/session_gate.dart';
import 'features/connectivity/connectivity_provider.dart';
import 'features/projects/projects_provider.dart';
import 'features/project_tasks/project_tasks_provider.dart';
import 'features/task_details/task_details_provider.dart';
import 'shared/widgets/offline_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Core services
  final storage = SecureStorageService();
  final connectivityService = ConnectivityService();
  final connectivityProvider = ConnectivityProvider(connectivityService)
    ..initialize();
  final api = ApiClient(storage: storage, connectivity: connectivityService);

  // Saved theme choice (system, light or dark), read before the first frame.
  final themeProvider = ThemeProvider();
  await themeProvider.load();

  // Repositories
  final authRepo = AuthRepository(api: api, storage: storage);
  final projectRepo = ProjectRepository(api);
  final taskRepo = TaskRepository(api);

  // Providers
  final authProvider = AuthProvider(authRepo);
  final projectsProvider = ProjectsProvider(projectRepo);
  final projectTasksProvider = ProjectTasksProvider(taskRepo);
  final taskDetailsProvider = TaskDetailsProvider(taskRepo);

  // 401 → clear session and return to login.
  api.onUnauthorized = authProvider.handleUnauthorized;

  // Session ended (sign out or 401): drop every cached screen's data so the
  // next user never sees the previous one's projects, tasks or comments.
  authProvider.addListener(() {
    if (authProvider.status == AuthStatus.unauthenticated) {
      projectsProvider.clear();
      projectTasksProvider.clear();
      taskDetailsProvider.clear();
    }
  });

  // Restore session on startup.
  authProvider.restoreSession();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: projectsProvider),
        ChangeNotifierProvider.value(value: projectTasksProvider),
        ChangeNotifierProvider.value(value: taskDetailsProvider),
        ChangeNotifierProvider.value(value: connectivityProvider),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const BeemViewApp(),
    ),
  );
}

class BeemViewApp extends StatelessWidget {
  const BeemViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeemView 360',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: context.select<ThemeProvider, ThemeMode>((p) => p.mode),
      builder: (context, child) => OfflineBanner(child: child!),
      home: const SessionGate(),
    );
  }
}
