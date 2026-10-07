import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/assets.dart';
import '../../core/colors.dart';
import '../../shared/widgets/beemview_wordmark.dart';
import '../shell/main_shell.dart';
import 'auth_provider.dart';
import 'login_screen.dart';

/// Decides which screen to show based on auth status.
class SessionGate extends StatelessWidget {
  const SessionGate({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;

    switch (status) {
      case AuthStatus.unknown:
        return const SplashLoading();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.authenticated:
        return const MainShell();
    }
  }
}

class SplashLoading extends StatelessWidget {
  const SplashLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.beemviewLogo,
                width: 72,
                height: 72,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              const BeemViewWordmark(fontSize: 26),
              const SizedBox(height: 40),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.beemBlue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
