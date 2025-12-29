import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:jumpmaster/core/Constants.dart';

class ProfileCompletionWidget extends StatelessWidget {
  final int percentage;

  const ProfileCompletionWidget({
    Key? key,
    required this.percentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progress = percentage.clamp(0, 100) / 100;

    return Container(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "profilecompletion".tr,
                style: TextStyle(
                  color: Constants.maintextColor,
                  fontSize: Constants.FS16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "$percentage%",
                style: TextStyle(
                  color: Constants.maintextColor,
                  fontSize: Constants.FS16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          /// Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                Constants.mainblue, // your main color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
