import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/connectivity_service.dart';
import 'core/secure_storage.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/project_repository.dart';
import 'data/repositories/task_repository.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/session_gate.dart';
import 'features/connectivity/connectivity_provider.dart';
import 'features/projects/projects_provider.dart';
import 'features/tasks/project_tasks_provider.dart';
import 'features/tasks/task_details_provider.dart';
import 'shared/widgets/offline_banner.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Core services
  final storage = SecureStorageService();
  final connectivityService = ConnectivityService();
  final connectivityProvider = ConnectivityProvider(connectivityService);
  final api = ApiClient(storage: storage, connectivity: connectivityService);

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
      title: 'BeemView',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const OfflineBanner(child: SessionGate()),
    );
  }
}
