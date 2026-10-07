import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/connectivity/connectivity_provider.dart';

/// Shows a red banner at the top of the app when the device is offline.
/// Collapses to zero height when online.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityProvider>().isOnline;

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: isOnline
              ? const SizedBox(width: double.infinity)
              : Material(
                  color: const Color(0xFFB00020),
                  child: SafeArea(
                    bottom: false,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Center(
                        child: Text(
                          'No internet connection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
