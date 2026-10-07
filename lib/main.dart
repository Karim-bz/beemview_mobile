import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/secure_storage.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/project_repository.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/session_gate.dart';
import 'features/projects/projects_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Core services
  final storage = SecureStorageService();
  final api = ApiClient(storage: storage);

  // Repositories
  final authRepo = AuthRepository(api: api, storage: storage);
  final projectRepo = ProjectRepository(api);

  // Providers
  final authProvider = AuthProvider(authRepo);
  final projectsProvider = ProjectsProvider(projectRepo);

  // 401 → clear session and return to login.
  api.onUnauthorized = authProvider.handleUnauthorized;

  // Restore session on startup.
  authProvider.restoreSession();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: projectsProvider),
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
      home: const SessionGate(),
    );
  }
}
