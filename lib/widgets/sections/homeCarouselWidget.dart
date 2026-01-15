import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jumpmaster/core/Constants.dart';
import 'package:jumpmaster/models/carousel.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeCarousel extends StatefulWidget {
  final List<HomeCarouselItem> items;

  const HomeCarousel({super.key, required this.items});

  @override
  State<HomeCarousel> createState() => _HomeCarouselState();
}

class _HomeCarouselState extends State<HomeCarousel> {
  final PageController _controller = PageController();
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Auto slide
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_controller.hasClients && widget.items.isNotEmpty) {
        _index = (_index + 1) % widget.items.length;
        _controller.animateToPage(
          _index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Container(
      height: Constants.sh / 4.2,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.items.length,
        itemBuilder: (context, i) {
          final item = widget.items[i];

          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                Image.network(
                  item.imageUrl,
                  fit: BoxFit.fill,
                ),

                // Button
                if (item.showButton)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.mainblue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      onPressed: () {
                        if (item.buttonUrl != null) {
                          _launch(item.buttonUrl!);
                        }
                      },
                      child: Text(
                        item.buttonText ?? "Open",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Constants.maintextColor),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
