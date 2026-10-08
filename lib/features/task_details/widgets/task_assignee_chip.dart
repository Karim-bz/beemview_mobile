import 'package:flutter/material.dart';

import '../../../core/colors.dart';
import '../../../shared/widgets/initials_avatar.dart';

class AssigneeChip extends StatelessWidget {
  const AssigneeChip({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 12, 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InitialsAvatar(name: name, radius: 11),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
