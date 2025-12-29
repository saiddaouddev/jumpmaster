import 'package:flutter/material.dart';
import 'package:jumpmaster/core/Constants.dart';
import 'package:jumpmaster/services/apiService.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String username = "";
  String avatar = "";
  String fullname = "";
  String displayname = "";
  String email = "";
  String phone = "";
  bool settings = false;
  Future<void> getMe() async {
    final Map<String, dynamic> data =
        await ApiService.callApi(api: "me", method: "GET");

    if (data["success"] == true) {
      setState(() {
        // profileCompletionvalue = data["profile_completion"] ?? 0;
        username = data["user"]["username"] ?? "";
        avatar = data["user"]["avatar"] ?? "";
        fullname = data["user"]["fullname"] ?? "";
        displayname = data["user"]["name"] ?? "";
        email = data["user"]["email"] ?? "";
        phone = data["user"]["phone"] ?? "";
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
        body: SafeArea(
            child: Padding(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedAlign(
                  duration: Duration(milliseconds: 100),
                  curve: Curves.easeInOut,
                  alignment: settings ? Alignment.topLeft : Alignment.center,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 100),
                    curve: Curves.easeInOut,
                    width: settings ? 60 : Constants.sw / 4,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.asset(avatar.isEmpty
                                  ? "assets/noprofile.jpg"
                                  : avatar),
                            ),
                            settings
                                ? Container()
                                : Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Constants.mainblue,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    )),
                          ],
                        ),
                        settings
                            ? Container()
                            : Text(
                                username,
                                style: TextStyle(
                                    color: Constants.maintextColor,
                                    fontWeight: FontWeight.bold),
                              )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        )));
  }
}
