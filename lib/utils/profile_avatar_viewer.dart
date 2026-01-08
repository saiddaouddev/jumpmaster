import 'package:flutter/material.dart';

class ProfileImageViewer extends StatelessWidget {
  final String heroTag;
  final ImageProvider imageProvider;

  const ProfileImageViewer({
    super.key,
    required this.heroTag,
    required this.imageProvider,
  });

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width * 0.75;

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      onVerticalDragEnd: (_) => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Hero(
            tag: heroTag,
            flightShuttleBuilder: (
              flightContext,
              animation,
              flightDirection,
              fromHeroContext,
              toHeroContext,
            ) {
              // Ensures smooth morph from CircleAvatar → big circle
              return ScaleTransition(
                scale: animation.drive(
                  Tween(begin: 1.0, end: 1.0)
                      .chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: toHeroContext.widget,
              );
            },
            child: ClipOval(
              child: Container(
                width: size,
                height: size,
                color: Colors.grey.shade900,
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 3,
                  child: Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
