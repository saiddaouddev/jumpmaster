import 'package:flutter/material.dart';

Widget statItem({required String value, required String label}) {
  return Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
        ),
      ),
    ],
  );
}
