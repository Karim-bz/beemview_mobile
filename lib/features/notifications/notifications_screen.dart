import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../shell/main_shell.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _BellIllustration(),
                      const SizedBox(height: 24),
                      const Text(
                        "You're all caught up",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Comments, status changes and new\n'
                        'assignments will show up here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: context.palette.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 22),
                      TextButton(
                        onPressed: () => onShellTabTap(context, 1),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.teal,
                          backgroundColor: context.palette.tealTint,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.m),
                          ),
                        ),
                        child: const Text(
                          'View my tasks',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft cloud blob with a checked bell and a few sparkles.
class _BellIllustration extends StatelessWidget {
  const _BellIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 190,
            height: 130,
            decoration: BoxDecoration(
              color: context.palette.tealTint,
              borderRadius: BorderRadius.circular(70),
            ),
          ),
          Positioned(
            right: 24,
            top: 2,
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFFD6ECF6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_rounded,
                size: 84,
                color: AppColors.teal,
              ),
              Positioned(
                top: 30,
                child: const Icon(
                  Icons.check_rounded,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Positioned(
            left: 18,
            top: 14,
            child: Icon(Icons.auto_awesome, size: 18, color: AppColors.teal),
          ),
          const Positioned(
            right: 14,
            top: 0,
            child: Icon(Icons.auto_awesome, size: 22, color: AppColors.orange),
          ),
          Positioned(left: 26, bottom: 28, child: _dot(AppColors.orange, 6)),
          Positioned(right: 22, bottom: 36, child: _dot(AppColors.green, 7)),
        ],
      ),
    );
  }

  Widget _dot(Color c, double s) => Container(
    width: s,
    height: s,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}
