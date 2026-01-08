import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpmaster/core/Constants.dart';
import 'package:jumpmaster/core/storage.dart';
import 'package:jumpmaster/screens/auth/authpage.dart';
import 'package:jumpmaster/screens/home/landingpage.dart';
import 'package:jumpmaster/services/apiService.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  String deviceid = "";
  String devicename = "";
  String appversion = "";
  bool authenticating = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constants.backgroundcolor,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: Constants.sw / 4,
                height: Constants.sw / 4,
                child: Stack(
                  children: [
                    Center(
                        child: Container(
                            width: Constants.sw / 4,
                            height: Constants.sw / 4,
                            child: CircularProgressIndicator(
                                strokeWidth: 4, color: Constants.mainblue))),
                    Padding(
                      padding: EdgeInsets.all(1.5),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.asset(
                            "assets/logo.png",
                          )),
                    ),
                  ],
                ),
              )

              // Text(
              //   authenticating ? "signingin".tr : "initializing".tr,
              //   style: TextStyle(
              //     color: Constants.maintextColor,
              //     fontSize: Constants.FS18,
              //   ),
              // ),
              // SizedBox(
              //   height: 10,
              // ),
            ],
          ),
        ));
  }

  void initApp() async {
    if (pref.read("token") == null || pref.read("token") == "") {
      getDeviceInfo();
    } else {
      Future.delayed(Duration(seconds: 1), () {
        signin();
      });
    }
  }

  void getDeviceInfo() async {
    // 🔹 App version
    final packageInfo = await PackageInfo.fromPlatform();
    appversion = "${packageInfo.version}+${packageInfo.buildNumber}";

    // 🔹 Device info
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceid = androidInfo.id; // unique per device build
      devicename = "${androidInfo.brand} ${androidInfo.model}";
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceid = iosInfo.identifierForVendor ?? "unknown";
      devicename = "${iosInfo.name} ${iosInfo.model}";
    }

    // 🔹 Save to preferences
    pref.write("deviceid", deviceid);
    pref.write("devicename", devicename);
    pref.write("appversion", appversion);
    setState(() {
      authenticating = false;
    });
    Future.delayed(Duration(seconds: 2), () {
      context.go('/auth');
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => AuthPage()),
      // );
    });
  }

  void signin() async {
    authenticating = true;

    var data = await ApiService.callApi(
      api: 'signin',
      method: 'POST',
      data: {"phone": pref.read("phone"), "token": pref.read("token")},
    );
    if (data["success"] != null && data["success"] == true) {
      pref.write("token", data["token"]);

      context.go('/home');
      //enterapp
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => HomePage()),
      // );
    } else {
      pref.write("token", null);
      pref.write("phone", null);
      authenticating = false;

      context.go('/auth');
    }
    setState(() {});
  }
}
