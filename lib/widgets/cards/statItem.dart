import 'package:flutter/material.dart';
import 'package:jumpmaster/core/Constants.dart';

Widget statItem({required String value, required String label}) {
  return Column(
    children: [
      Text(
        value,
        style: TextStyle(
          color: Colors.white,
          fontSize: Constants.FS26,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          color: Colors.white70,
          fontSize: Constants.FS12,
        ),
      ),
    ],
  );
}

Widget todayItem(String value, String label) {
  return Column(
    children: [
      Text(
        value,
        style: TextStyle(
          color: Colors.white,
          fontSize: Constants.FS18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: TextStyle(
          color: Colors.white70,
          fontSize: Constants.FS10,
        ),
      ),
    ],
  );
}
