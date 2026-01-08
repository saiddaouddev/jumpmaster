import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:jumpmaster/core/Constants.dart';
import 'package:jumpmaster/core/sound_manager.dart';
import 'package:jumpmaster/core/storage.dart';
import 'package:jumpmaster/core/vibration_manager.dart';
import 'package:jumpmaster/screens/auth/authpage.dart';
import 'package:jumpmaster/screens/home/homepage.dart';
import 'package:jumpmaster/screens/home/leaderboard.dart';
import 'package:jumpmaster/screens/home/profile.dart';
import 'package:jumpmaster/screens/home/workoutpage.dart';
import 'package:jumpmaster/services/apiService.dart';
import 'package:jumpmaster/widgets/sections/profilecompletion.dart';
import 'package:permission_handler/permission_handler.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 1;
  final List<Widget> _pages = const [
    HomePage(),
    LeaderboardPage(),
    WorkoutPage(),
    Profile(),
  ];
  Future<void> getMe() async {
    final Map<String, dynamic> data =
        await ApiService.callApi(api: "me", method: "GET");

    if (data["success"] == true) {
      Constants.profileCompletion.value = data["profile_completion"] ?? 0;
    }
  }

  Future<void> requestNotificationPermission() async {
    await Permission.notification.request();
  }

  @override
  void initState() {
    requestNotificationPermission();
    getMe();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundcolor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.asset("assets/logo.png", height: 40, width: 40))
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedFontSize: Constants.FS14,
        selectedFontSize: Constants.FS16,
        backgroundColor: Constants.backgroundcolor,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Constants.mainblue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'home'.tr,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'leaderboard'.tr,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'workout'.tr,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'profile'.tr,
          ),
        ],
      ),
      body: Column(
        children: [
          ValueListenableBuilder<int>(
            valueListenable: Constants.profileCompletion,
            builder: (context, value, _) {
              if (value == 100 || _currentIndex == 1) {
                return Container();
              }

              return Column(
                children: [
                  ProfileCompletionWidget(
                    percentage: value,
                  ),
                  const SizedBox(height: 5),
                ],
              );
            },
          ),
          Expanded(child: _pages[_currentIndex])
        ],
      ),
    );
  }
}
