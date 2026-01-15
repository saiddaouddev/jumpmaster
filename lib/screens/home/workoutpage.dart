import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:jumpmaster/core/Constants.dart';
import 'package:jumpmaster/core/sound_manager.dart';
import 'package:jumpmaster/core/vibration_manager.dart';
import 'package:jumpmaster/services/apiService.dart';
import 'package:jumpmaster/widgets/cards/statItem.dart';
import 'package:jumpmaster/widgets/cards/statchip.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  // SESSION
  bool isFreeRunning = false;
  int jumps = 0;
  int workoutSeconds = 0;
  int sessionid = 0;
  Timer? freeTimer;

  // STATS
  String sessionJumps = "0";
  String sessionDuration = "00:00";
  String sessionCalories = "0";
  String todayTotalJumps = "0";
  String todayTotalDuration = "0";
  String todayTotalCalories = "0";
  String todaySessions = "0";
  String today_date = "";
  String user_avatar = "";

  // ANIMATION
  late AnimationController _anim;
  late Animation<double> _fade;
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  @override
  void initState() {
    super.initState();

    soundEnabled = SoundManager().isEnabled;
    vibrationEnabled = VibrationManager().isEnabled;
    WidgetsBinding.instance.addObserver(this);

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();

    getMystats();
  }

  Future<void> getMystats() async {
    final data = await ApiService.callApi(api: "stats/me", method: "GET");

    if (data["success"] == true && data["today"] != null) {
      final today = data["today"];
      final user = data["user"];
      today_date = data["date"];

      setState(() {
        user_avatar = "http://192.168.1.108:8000" + user["avatar"].toString();
        todayTotalJumps = today["total_jumps"].toString();
        todayTotalDuration = today["total_duration_seconds"].toString();
        todayTotalCalories = today["total_calories"].toString();
        todaySessions = today["total_sessions"].toString();
        // statsLoading = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    freeTimer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  // APP BACKGROUND HANDLING
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && isFreeRunning) {
      freeTimer?.cancel();
    }
  }

  // ------------------- SESSION -------------------

  Future<void> startSession() async {
    if (isFreeRunning) return;

    final data = await ApiService.callApi(api: "workout/start", method: "POST");

    if (data["success"] == true) {
      sessionid = data["session_id"];
      jumps = 0;
      workoutSeconds = 0;

      setState(() => isFreeRunning = true);

      freeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => workoutSeconds++);
      });

      SoundManager().play("start.mp3");
      VibrationManager().vibrate(duration: 200);
    }
  }

  bool sessionEnded = false;

  Future<void> endSession() async {
    if (!isFreeRunning) return;

    freeTimer?.cancel();

    final data = await ApiService.callApi(
      api: "workout/end",
      method: "POST",
      data: {
        "session_id": sessionid,
        "jumps": jumps,
        "duration_seconds": workoutSeconds,
      },
    );

    if (data["success"] == true) {
      final session = data["session"];
      final todayStats = data["today_stats"];

      sessionJumps = session["jumps"].toString();
      sessionDuration = formatTime(session["duration_seconds"]);
      sessionCalories = session["calories"].round().toString();

      todayTotalJumps = todayStats["total_jumps"].toString();
      todaySessions = todayStats["total_sessions"].toString();

      VibrationManager().vibrate(duration: 400);

      setState(() => isFreeRunning = false);

      sessionEnded = true;
      getMystats();
    }
  }

  // ------------------- UI HELPERS -------------------

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundcolor,
      body: FadeTransition(
        opacity: _fade,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              myworkoutsWidget(),
              const SizedBox(height: 25),
              sessionEnded
                  ? Container(
                      height: Constants.sh / 2,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Constants.mainblue,
                            Constants.mainblue.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.emoji_events_rounded,
                              color: Colors.white, size: 40),
                          const SizedBox(height: 10),
                          Text(
                            "workoutcompleted".tr,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: Constants.FS22,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              statItem(value: sessionJumps, label: "jumps".tr),
                              statItem(
                                  value: sessionDuration, label: "duration".tr),
                              statItem(
                                  value: sessionCalories, label: "calories".tr),
                            ],
                          ),
                          const SizedBox(height: 25),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                todayItem(
                                    todayTotalJumps, "todaytotaljumps".tr),
                                todayItem(todaySessions, "sessionstoday".tr),
                              ],
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                sessionEnded = false;
                                jumps = 0;
                                workoutSeconds = 0;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  "done".tr,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  : workoutCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget workoutCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(formatTime(workoutSeconds),
              style: TextStyle(
                  fontSize: Constants.FS28,
                  fontWeight: FontWeight.w600,
                  color: Constants.maintextColor)),
          const SizedBox(height: 10),
          Text("$jumps",
              style: TextStyle(
                  fontSize: Constants.FS40,
                  fontWeight: FontWeight.bold,
                  color: Constants.maintextColor)),
          Text(
            "jumps".tr,
            style: TextStyle(color: Constants.maintextColor),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: actionButton(
                  text: isFreeRunning ? "stop".tr : "start".tr,
                  color: isFreeRunning ? Colors.red : Constants.mainblue,
                  onTap: isFreeRunning ? endSession : startSession,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: actionButton(
                  text: "+ Jump",
                  color: Colors.blueGrey,
                  onTap: isFreeRunning
                      ? () {
                          setState(() {
                            jumps++;

                            if (jumps > 0 && jumps % 100 == 0) {
                              SoundManager().play("start.mp3");
                            }
                          });
                        }
                      : null,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget actionButton(
      {required String text, required Color color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey : color,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(text,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget myworkoutsWidget() {
    return Container(
      width: Constants.sw,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.18),
            Colors.white.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                userAvatar(size: 34),
                SizedBox(width: 6),
                Text(
                  "todayworkout".tr,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: Constants.FS14,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ]),
              Row(
                children: [
                  Text(
                    today_date,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: Constants.FS14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 12),

          // MAIN STAT
          Text(
            "$todayTotalJumps",
            style: TextStyle(
              color: Colors.white,
              fontSize: Constants.FS36,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          Text(
            "totaljumps".tr,
            style: TextStyle(
              color: Colors.white70,
              fontSize: Constants.FS14,
            ),
          ),

          const SizedBox(height: 16),

          // SECONDARY STATS
          Row(
            children: [
              statChip(
                icon: Icons.timer_outlined,
                label: "$todayTotalDuration sec",
              ),
              const SizedBox(width: 10),
              statChip(
                icon: Icons.local_fire_department_outlined,
                label: "$todayTotalCalories cal",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget userAvatar({double size = 36}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: Image.network(
          user_avatar, // <-- your avatar URL
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.person,
            color: Colors.white70,
            size: size * 0.6,
          ),
        ),
      ),
    );
  }
}
