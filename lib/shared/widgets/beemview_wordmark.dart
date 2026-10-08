import 'package:flutter/material.dart';

import '../../core/colors.dart';

class BeemViewWordmark extends StatelessWidget {
  const BeemViewWordmark({super.key, this.fontSize = 26});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
        ),
        children: const [
          TextSpan(
            text: 'BeemView',
            style: TextStyle(color: AppColors.teal),
          ),
          TextSpan(
            text: ' 360',
            style: TextStyle(color: AppColors.orange),
          ),
        ],
      ),
    );
  }
}
