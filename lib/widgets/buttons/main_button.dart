import 'package:flutter/material.dart';
import 'package:jumpmaster/core/Constants.dart';

class MainButton extends StatelessWidget {
  final String str;

  final Gradient? background;
  final VoidCallback? onTap;

  const MainButton({super.key, required this.str, this.background, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(left: 24, right: 24),
        margin: EdgeInsets.only(bottom: 20),
        height: 56,
        decoration: BoxDecoration(
          color: Constants.mainblue,
          // gradient: LinearGradient(
          //   colors: [
          //     Constants.mainblue,
          //     Constants.mainblue, // darker green bottom-right
          //     // bright green top-left
          //   ],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Constants.mainblue.withOpacity(0.5),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Center(
          child: Text(
            str,
            style: TextStyle(
              fontSize: Constants.FS14,
              color: Constants.maintextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
