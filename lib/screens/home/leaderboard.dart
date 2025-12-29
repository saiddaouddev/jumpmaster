import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:jumpmaster/services/apiService.dart';
import 'package:jumpmaster/widgets/cards/podium3d.dart';

import '../../core/Constants.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _hideTimer;
  bool infobanner = true;

  Future<void> getLeaderboardData() async {
    // Placeholder for future leaderboard data fetching logic
    final Map<String, dynamic> data =
        await ApiService.callApi(api: "leaderboard/month", method: "GET");
  }

  void showMonthlyBanner() {
    _hideTimer?.cancel();

    setState(() {
      infobanner = true;
    });

    _fadeController.reset();

    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;

      _fadeController.forward().then((_) {
        if (mounted) {
          setState(() {
            infobanner = false; // REMOVE from layout
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getLeaderboardData();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );

    // Show banner on page entry
    showMonthlyBanner();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundcolor,
      body: Column(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: infobanner ? monthlyInfoBanner() : SizedBox.shrink(),
          ),
          _podium(),
          const SizedBox(height: 40),
          _rankList(),
        ],
      ),
    );
  }

  // ================= FILTERS =================
  Widget _filters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _chip("Worldwide", true),
          _chip("United States", false),
          _chip("Florida", false),
          _chip("Europe", false),
        ],
      ),
    );
  }

  Widget _chip(String text, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.black : Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ================= PODIUM =================
  Widget _podium() {
    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 2nd place
          Transform.translate(
            offset: const Offset(-110, 30),
            child: _podiumItem(
              rank: 2,
              height: 120,
              name: "joshele...",
              score: 105,
            ),
          ),

          // 1st place
          Transform.translate(
            offset: const Offset(0, 0),
            child: _podiumItem(
              rank: 1,
              height: 160,
              name: "lilyonetw...",
              score: 146,
              crown: true,
            ),
          ),

          // 3rd place
          Transform.translate(
            offset: const Offset(110, 30),
            child: _podiumItem(
              rank: 3,
              height: 100,
              name: "herotaylo...",
              score: 99,
            ),
          ),
        ],
      ),
    );
  }

  Widget _podiumItem({
    required int rank,
    required double height,
    required String name,
    required int score,
    bool crown = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: const NetworkImage(
                "https://i.pravatar.cc/150",
              ),
            ),
            if (crown)
              const Positioned(
                top: -20,
                right: -5,
                child: Icon(Icons.emoji_events, color: Colors.amber),
              ),
            Positioned(
              bottom: -5,
              right: -5,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.amber,
                child: Text(
                  "$rank",
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon(Icons.circle, color: Constants.mainblue, size: 10),
            // const SizedBox(width: 4),
            Text(
              "$score",
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),

        // PODIUM BLOCK
        Podium3D(
          width: 80,
          height: 100,
          number: "$rank",
        ),
      ],
    );
  }

  // ================= LIST =================
  Widget _rankList() {
    return Expanded(
      child: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (_, i) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Text(
                  "${i + 4}",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 12),
                const CircleAvatar(
                  backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "player_name",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Icon(Icons.circle, color: Constants.mainblue, size: 10),
                const SizedBox(width: 6),
                const Text(
                  "96",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget monthlyInfoBanner() {
    return Container(
      margin:
          EdgeInsets.fromLTRB(16, infobanner ? 8 : 0, 16, infobanner ? 12 : 0),
      padding: EdgeInsets.symmetric(
          horizontal: infobanner ? 14 : 0, vertical: infobanner ? 10 : 0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: Colors.white70,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "scoresresetinfo".tr,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
