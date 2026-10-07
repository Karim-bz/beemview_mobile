import 'package:beemview_mobile/core/colors.dart';
import 'package:flutter/material.dart';

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
          letterSpacing: -0.5,
        ),
        children: const [
          TextSpan(
            text: 'BeemView',
            style: TextStyle(color: AppColors.beemBlue),
          ),
          TextSpan(
            text: ' 360',
            style: TextStyle(color: AppColors.beemOrange),
          ),
        ],
      ),
    );
  }
}
