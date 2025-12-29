
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jumpmaster/core/Constants.dart';

class Thememode {
  static setTheme() {
    var pref = GetStorage();
    if (pref.read("theme") != null) {
      if (pref.read("theme") == "light") {
        Constants.backgroundcolor = Colors.white;
        Constants.maingreen = Color.fromARGB(255, 97, 178, 49);
        Constants.mainblue = Color.fromARGB(255, 45, 151, 212);
        Constants.lightblue = Color.fromARGB(255, 180, 219, 255);
        Constants.lightestblue = Color.fromARGB(255, 234, 242, 255);
        Constants.bordergrey = Color.fromARGB(255, 231, 231, 231);
        Constants.textgrey = Color.fromARGB(255, 135, 136, 146);
        Constants.maintextColor = Color.fromARGB(255, 75, 75, 75);
        Constants.lightgrey = Color.fromARGB(255, 250, 250, 250);
        Constants.mainred = Color.fromARGB(255, 198, 19, 19);
      } else if (pref.read("theme") == "dark") {
        Constants.backgroundcolor =
            Color.fromARGB(255, 18, 18, 18); // Dark background
        Constants.maingreen =
            Color.fromARGB(255, 80, 160, 60); // Slightly darker green
        Constants.mainblue =
            Color.fromARGB(255, 35, 130, 190); // Darker blue for contrast
        Constants.lightblue =
            Color.fromARGB(255, 100, 170, 230); // Muted light blue
        Constants.lightestblue =
            Color.fromARGB(255, 33, 33, 33); // Darker but noticeable light blue
        Constants.bordergrey =
            Color.fromARGB(255, 60, 60, 60); // Dark grey for subtle borders
        Constants.textgrey =
            Color.fromARGB(255, 180, 180, 180); // Lighter grey for readability
        Constants.maintextColor = Color.fromARGB(
            255, 220, 220, 220); // Lighter text for dark backgrounds
        Constants.lightgrey =
            Color.fromARGB(255, 159, 159, 159); // Near-black light grey
        Constants.mainred =
            Color.fromARGB(255, 220, 60, 60); // Brighter red for visibility
      }
    }
    Get.forceAppUpdate();
  }
}
