import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jumpmaster/core/Constants.dart';
import 'package:jumpmaster/models/achievements.dart';

class AchievementTrainItem extends StatelessWidget {
  final int index;
  final Achievement achievement;
  final bool isLast;
  final bool previousUnlocked;

  const AchievementTrainItem({
    Key? key,
    required this.index,
    required this.achievement,
    required this.isLast,
    required this.previousUnlocked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Constants.mainblue;
    final Color inactiveColor = Colors.grey.shade400;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Train line + circle
        Column(
          children: [
            // if (previousUnlocked)
            Container(
                width: 2,
                height: 30,
                color: index == 0
                    ? Colors.transparent
                    : achievement.unlocked
                        ? activeColor.withOpacity(0.6)
                        : inactiveColor.withOpacity(0.4)),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: achievement.unlocked ? activeColor : inactiveColor,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: achievement.unlocked
                    ? activeColor.withOpacity(0.6)
                    : inactiveColor.withOpacity(0.4),
              ),
          ],
        ),

        const SizedBox(width: 16),

        // Achievement card
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: achievement.unlocked
                  ? activeColor.withOpacity(0.1)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    achievement.unlocked ? activeColor : Colors.grey.shade400,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: achievement.unlocked
                        ? activeColor
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
