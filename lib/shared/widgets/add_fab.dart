import 'package:flutter/material.dart';

import '../../core/colors.dart';

/// Orange gradient "+" floating button.
class AddFab extends StatelessWidget {
  const AddFab({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFB04D), AppColors.orange],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.glow(AppColors.orange),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
