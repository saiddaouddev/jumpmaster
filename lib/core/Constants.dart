import 'package:flutter/material.dart';

class Constants {
  static String baseUrl = 'http://192.168.1.108:8000/api/';

  static double sw = 0.0;
  static double sh = 0.0;
  static ValueNotifier<int> profileCompletion = ValueNotifier<int>(0);

  // Font scale (default = 1.0)
  static double fontScale = 1.0;

  // Base font sizes
  static double FS10 = 10.0;
  static double FS12 = 12.0;
  static double FS14 = 14.0;
  static double FS16 = 16.0;
  static double FS18 = 18.0;
  static double FS20 = 20.0;
  static double FS22 = 22.0;
  static double FS24 = 24.0;
  static double FS26 = 26.0;
  static double FS28 = 28.0;
  static double FS36 = 36.0;
  static double FS40 = 36.0;
  static double FS56 = 56.0;
  static double FS60 = 60.0;

  // Call this when font size changes
  static void updateFontScale(double scale) {
    fontScale = scale;
    Constants.FS10 = 10.0 * fontScale;
    Constants.FS12 = 12.0 * fontScale;
    Constants.FS14 = 14.0 * fontScale;
    Constants.FS16 = 16.0 * fontScale;
    Constants.FS18 = 18.0 * fontScale;
    Constants.FS20 = 20.0 * fontScale;
    Constants.FS22 = 22.0 * fontScale;
    Constants.FS24 = 24.0 * fontScale;
    Constants.FS26 = 26.0 * fontScale;
    Constants.FS28 = 28.0 * fontScale;
    Constants.FS36 = 36.0 * fontScale;
    Constants.FS36 = 40.0 * fontScale;
    Constants.FS56 = 56.0 * fontScale;
    Constants.FS60 = 60.0 * fontScale;
  }

  //colors
  static Color backgroundcolor = const Color.fromARGB(255, 11, 11, 11);
  static Color maingreen = Color.fromARGB(255, 97, 178, 49);
  static Color mainblue = Color.fromARGB(255, 65, 198, 250);
  static Color lightblue = Color.fromARGB(255, 180, 219, 255);
  static Color lightestblue = Color.fromARGB(255, 234, 242, 255);
  static Color bordergrey = Color.fromARGB(255, 231, 231, 231);
  static Color textgrey = Color.fromARGB(255, 167, 168, 180);
  static Color maintextColor = Color.fromARGB(255, 255, 255, 255);
  static Color textlightgrey = Color.fromARGB(255, 179, 180, 193);
  static Color lightgrey = Color.fromARGB(255, 250, 250, 250);
  static Color mainred = Color.fromARGB(255, 198, 19, 19);
  static Color mainorange = Color.fromARGB(255, 244, 171, 0);

  static LinearGradient mainLinearGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Constants.mainblue,
      const Color(0xFF0A0A0A),
    ],
  );

  static List<Color> messageBackColor = [
    Color.fromARGB(255, 234, 242, 255),
    Color.fromARGB(255, 210, 254, 213),
    Color.fromARGB(255, 255, 235, 210),
    Color.fromARGB(255, 255, 195, 195),
  ];
  static List<Color> messageTitleColor = [
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
  ];
  static List<Color> messageTextColor = [
    Color.fromARGB(255, 45, 151, 212),
    Color.fromARGB(255, 42, 140, 18),
    Color.fromARGB(255, 189, 119, 20),
    Color.fromARGB(255, 170, 25, 25),
  ];

  //font size
  // static double FS1 = 11;
  // static double FS2 = 13;
  // static double FS3 = 15;
  // static double FS4 = 17;
  // static double FS5 = 19;
  // static double FS6 = 21;
  // static double FS7 = 23;
  // static double FS8 = 25;
  // static double FS9 = 30;
  // static double FS10 = 36;
}
