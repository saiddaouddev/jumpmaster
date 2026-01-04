import 'package:flutter/material.dart';
import 'package:jumpmaster/core/Constants.dart';
import 'package:jumpmaster/widgets/cards/statItemShare.dart';

class ShareWorkoutCard extends StatelessWidget {
  final String jumps;
  final int timeSeconds;
  final String calories;

  const ShareWorkoutCard({
    super.key,
    required this.jumps,
    required this.timeSeconds,
    required this.calories,
  });

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080, // High quality
      height: 1350,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Jumps

          Text(
            jumps.toString(),
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: Constants.mainblue,
            ),
          ),
          const Text(
            "JUMPS",
            style: TextStyle(
              letterSpacing: 4,
              fontSize: 26,
              color: Colors.white70,
            ),
          ),
          SizedBox(
            height: 40,
          ),

          /// Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StatItem(
                icon: Icons.timer,
                value: formatTime(timeSeconds),
                label: "TIME",
              ),
              StatItem(
                icon: Icons.local_fire_department,
                value: "$calories",
                label: "KCAL",
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),

          /// Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Logo
              ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.asset(
                    "assets/logo.png",
                    height: 30,
                  )),
              SizedBox(
                width: 15,
              ),
              const Text(
                "#JumpMaster",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 20,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
