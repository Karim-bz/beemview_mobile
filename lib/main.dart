import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/secure_storage.dart';
import 'data/repositories/auth_repository.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/session_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = SecureStorageService();
  final api = ApiClient(storage: storage);
  final authRepo = AuthRepository(api: api, storage: storage);
  final authProvider = AuthProvider(authRepo);

  // When a protected call returns 401, clear the session and go to login.
  api.onUnauthorized = authProvider.handleUnauthorized;

  // Restore session on startup (runs in the background).
  authProvider.restoreSession();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: authProvider)],
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
