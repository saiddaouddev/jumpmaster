import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:jumpmaster/core/Constants.dart';
import 'package:jumpmaster/models/carousel.dart';
import 'package:jumpmaster/models/product.dart';
import 'package:jumpmaster/services/apiService.dart';
import 'package:jumpmaster/widgets/sections/homeCarouselWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<HomeCarouselItem> carouselItems = [];
  List<HomeProduct> productItems = [];
  bool loadingCarousel = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCarousel();
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeCarousel(items: carouselItems),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                textAlign: TextAlign.start,
                "ourproducts".tr,
                style: TextStyle(
                    color: Constants.maintextColor,
                    fontSize: Constants.FS16,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                textAlign: TextAlign.start,
                "visitwebsite".tr,
                style: TextStyle(
                    color: Constants.mainblue, fontSize: Constants.FS12),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Container(
              height: Constants.sw / 2.1,
              child: ListView.builder(
                padding: EdgeInsets.all(0),
                scrollDirection: Axis.horizontal,
                itemCount: productItems.length,
                itemBuilder: (context, i) {
                  final p = productItems[i];
                  return GestureDetector(
                    onTap: () => launchUrl(Uri.parse(p.url)),
                    child: Container(
                        width: Constants.sw / 3,
                        margin: EdgeInsets.only(right: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: Constants.sw / 3.20,
                                height: Constants.sw / 2.8,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: loadingProducts
                                            ? Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                                size: 32,
                                              )
                                            : Image.network(
                                                p.imageUrl,
                                                width: 100,
                                                fit: BoxFit.fill,
                                              )),
                                    p.price == 0
                                        ? Container()
                                        : Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Container(
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    color: Constants.mainblue
                                                        .withOpacity(0.8),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topRight: Radius
                                                                .circular(10),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10))),
                                                child: Text(
                                                  p.price.toString() + " \$",
                                                  style: TextStyle(
                                                      color: Constants
                                                          .maintextColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: Constants.FS12),
                                                )))
                                  ],
                                )),
                            const SizedBox(height: 6),
                            Text(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              p.name,
                              style: TextStyle(
                                  color: Constants.maintextColor,
                                  fontSize: Constants.FS14),
                            ),
                          ],
                        )),
                  );
                },
              ))
        ],
      ),
    );
  }

  Future<void> getCarousel() async {
    try {
      loadingCarousel = true;

      final Map<String, dynamic> data = await ApiService.callApi(
        api: "home/carousel",
        method: "GET",
      );

      if (!mounted) return;

      final List<HomeCarouselItem> items = (data["data"] as List)
          .map((e) => HomeCarouselItem.fromJson(e))
          .toList();

      setState(() {
        carouselItems = items;
        loadingCarousel = false;
      });
    } catch (e) {
      debugPrint("Carousel error: $e");
      if (!mounted) return;
      setState(() {
        loadingCarousel = false;
      });
    }
  }

  bool loadingProducts = false;
  Future<void> getProducts() async {
    try {
      loadingProducts = true;

      final Map<String, dynamic> data = await ApiService.callApi(
        api: "home/products",
        method: "GET",
      );

      if (!mounted) return;

      final List<HomeProduct> items =
          (data["data"] as List).map((e) => HomeProduct.fromJson(e)).toList();

      setState(() {
        productItems = items;
        loadingProducts = false;
      });
    } catch (e) {
      debugPrint("Carousel error: $e");
      if (!mounted) return;
      setState(() {
        loadingProducts = false;
      });
    }
  }
}
