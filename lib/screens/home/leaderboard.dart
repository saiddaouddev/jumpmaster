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
  Timer? _hideTimer;
  bool infobanner = true;
  List<dynamic> leaderboard = [];
  bool loadingLeaderboard = true;
  String periodType = "month"; // month | week

  int? myRank;
  int? myTotalJumps;

  Map<String, dynamic> _getPodiumData(int index) {
    if (leaderboard.length > index) {
      return {
        "exists": true,
        "name": leaderboard[index]["display_name"],
        "score": leaderboard[index]["total_jumps"],
        "avatar": leaderboard[index]["avatar"],
      };
    }

    // Placeholder
    return {
      "exists": false,
      "name": "---",
      "score": 0,
      "avatar": null,
    };
  }

  Future<void> getLeaderboardData(String periodType) async {
    loadingLeaderboard = true;
    final Map<String, dynamic> data =
        await ApiService.callApi(api: "leaderboard/$periodType", method: "GET");

    if (!mounted) return;

    setState(() {
      leaderboard = data["leaderboard"] ?? [];
      myRank = data["my_rank"];
      myTotalJumps = data["my_total_jumps"];
      loadingLeaderboard = false;
    });
  }

  Widget _periodToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _periodButton("Week"),
          const SizedBox(width: 8),
          _periodButton("Month"),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getLeaderboardData(periodType);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundcolor,
      body: Column(
        children: [
          _periodToggle(),
          _podium(),
          const SizedBox(height: 40),
          _myRankCard(),
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
    if (!loadingLeaderboard && leaderboard.isEmpty) {
      return _emptyLeaderboard();
    }
    if (loadingLeaderboard) {
      return const SizedBox(height: 260);
    }

    final first = _getPodiumData(0);
    final second = _getPodiumData(1);
    final third = _getPodiumData(2);

    return Container(
      width: Constants.sw,
      height: 300,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 2nd place
          Transform.translate(
            offset: const Offset(-110, 30),
            child: _podiumItem(
              rank: 2,
              height: 120,
              name: second["name"],
              score: second["score"],
              avatar: second["avatar"].toString(),
              placeholder: !second["exists"],
            ),
          ),

          // 1st place
          Transform.translate(
            offset: const Offset(0, 0),
            child: _podiumItem(
              rank: 1,
              height: 130,
              name: first["name"],
              score: first["score"],
              avatar: first["avatar"].toString(),
              crown: true,
              placeholder: !first["exists"],
            ),
          ),

          // 3rd place
          Transform.translate(
            offset: const Offset(110, 30),
            child: _podiumItem(
              rank: 3,
              height: 110,
              name: third["name"],
              score: third["score"],
              avatar: third["avatar"],
              placeholder: !third["exists"],
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
    String? avatar,
    bool crown = false,
    bool placeholder = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor:
                  placeholder ? Colors.grey.shade700 : Colors.transparent,
              backgroundImage: placeholder
                  ? null
                  : NetworkImage("http://192.168.1.104:8000" + avatar!),
              child: placeholder
                  ? const Icon(Icons.person, color: Colors.white24)
                  : null,
            ),
            if (crown && !placeholder)
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
                  style: TextStyle(
                    fontSize: Constants.FS12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          name,
          style: TextStyle(
            color: placeholder ? Colors.white38 : Colors.white,
          ),
        ),

        const SizedBox(height: 4),

        if (!placeholder)
          Text(
            "$score",
            style: const TextStyle(color: Colors.white70),
          ),

        // PODIUM BLOCK
        Podium3D(
          width: 80,
          height: height,
          number: "$rank",
        ),
      ],
    );
  }

  // ================= LIST =================
  Widget _rankList() {
    if (leaderboard.length <= 3) {
      return const SizedBox.shrink();
    }

    return Expanded(
      child: ListView.builder(
        itemCount: leaderboard.length - 3,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (_, i) {
          final item = leaderboard[i + 3];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Text(
                  "${i + 4}",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    Constants.baseUrl + item["avatar"],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item["display_name"],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Icon(Icons.circle, color: Constants.mainblue, size: 10),
                const SizedBox(width: 6),
                Text(
                  "${item["total_jumps"]}",
                  style: const TextStyle(color: Colors.white),
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
      width: Constants.sw,
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
                fontSize: Constants.FS14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodButton(String type) {
    final bool active = periodType == type.toLowerCase();

    return GestureDetector(
      onTap: () {
        if (active) return;

        setState(() {
          periodType = type.toLowerCase();
        });

        getLeaderboardData(periodType);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          type,
          style: TextStyle(
            color: active ? Colors.black : Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _myRankCard() {
    if (myRank == null || myTotalJumps == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Constants.mainblue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Constants.mainblue),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "me".tr,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            "#$myRank",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(width: 10),
          Icon(Icons.circle, color: Constants.mainblue, size: 8),
          const SizedBox(width: 6),
          Text(
            "$myTotalJumps",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _emptyLeaderboard() {
    return Container(
      width: Constants.sw,
      height: 260,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.emoji_events, size: 48, color: Colors.white24),
          SizedBox(height: 12),
          Text(
            "Be the first 🔥",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Start a workout and claim the top spot",
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }
}
