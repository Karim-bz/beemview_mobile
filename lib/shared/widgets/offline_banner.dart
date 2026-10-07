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
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isOnline ? 0 : 32,
          color: const Color(0xFFB00020),
          child: isOnline
              ? null
              : const Center(
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
        Expanded(child: child),
      ],
    );
  }
}
