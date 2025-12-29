import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jumpmaster/core/Constants.dart';
import 'package:jumpmaster/screens/auth/authpage.dart';
import 'package:jumpmaster/screens/auth/splashscreen.dart';
import 'package:jumpmaster/screens/home/landingpage.dart';
import 'package:jumpmaster/theme/ThemeMode.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpmaster/translations/localstrings.dart';

var pref = GetStorage();
updateLocale() {
  if (pref.read('lang') != null) {
    if (pref.read('lang') == "en_US") {
      Get.updateLocale(Locale('en', 'US'));
    } else if (pref.read('lang') == "ar_AR") {
      Get.back;
      Get.updateLocale(Locale('ar', 'AR'));
    } else if (pref.read('lang') == "fr_FR") {
      Get.back;
      Get.updateLocale(Locale('fr', 'FR'));
    }
  } else {
    pref.write("lang", "en_US");
    Get.updateLocale(Locale('en', 'US'));
  }
  Thememode.setTheme();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  log("##########################################");
  updateLocale();
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return SplashScreen();
        },
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) {
          return AuthPage();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => LandingPage(),
      ),
    ],
  );
  runApp(MyApp(router: router));
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  MyApp({required this.router});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Constants.sw = MediaQuery.of(context).size.width;
    Constants.sh = MediaQuery.of(context).size.height;
    return GetMaterialApp.router(
      title: 'jumpmaster',
      translations: LocaleString(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
