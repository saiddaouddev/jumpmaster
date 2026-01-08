import 'package:flutter/material.dart';
import 'package:jumpmaster/core/Constants.dart';

Widget statChip({required IconData icon, required String label}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: Constants.FS12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
