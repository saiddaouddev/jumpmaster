import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:jumpmaster/core/Constants.dart';
import 'package:jumpmaster/core/storage.dart';
import 'package:jumpmaster/screens/auth/authpage.dart';
import 'package:jumpmaster/screens/home/homepage.dart';
import 'package:jumpmaster/screens/home/leaderboard.dart';
import 'package:jumpmaster/screens/home/profile.dart';
import 'package:jumpmaster/screens/home/workoutpage.dart';
import 'package:jumpmaster/services/apiService.dart';
import 'package:jumpmaster/widgets/sections/profilecompletion.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 1;
  int profileCompletionvalue = 0;
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
      setState(() {
        profileCompletionvalue = data["profile_completion"] ?? 0;
      });
    }
  }

  @override
  void initState() {
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
          profileCompletionvalue == 100 || _currentIndex == 1
              ? Container()
              : ProfileCompletionWidget(
                  percentage: profileCompletionvalue, // from 0 to 100
                ),
          profileCompletionvalue == 100 || _currentIndex == 1
              ? Container()
              : SizedBox(
                  height: 5,
                ),
          Expanded(child: _pages[_currentIndex])
        ],
      ),
    );
  }
}
