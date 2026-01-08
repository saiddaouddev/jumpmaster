import 'package:flutter/material.dart';
import 'package:jumpmaster/core/Constants.dart';

class Podium3D extends StatelessWidget {
  final double width;
  final double height;
  final String number;

  const Podium3D({
    super.key,
    required this.width,
    required this.height,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width + 20,
      height: height + 30,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // FRONT FACE
          Positioned(
            bottom: 0,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E2E),
              ),
              alignment: Alignment.center,
              child: Text(
                number,
                style: TextStyle(
                  fontSize: Constants.FS56,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
            ),
          ),

          // TOP FACE (3D illusion)
          Positioned(
            bottom: height - 2,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(-0.8),
              alignment: Alignment.bottomCenter,
              child: Container(
                width: width,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A4A4A),
                ),
              ),
            ),
          ),

          // SIDE SHADOW
          Positioned(
            right: 6,
            bottom: 0,
            child: Container(
              width: 4,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.0),
                    const Color.fromARGB(255, 255, 255, 255).withOpacity(0.08),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
