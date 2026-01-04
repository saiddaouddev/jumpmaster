import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jumpmaster/core/Constants.dart';

class AppConfirmSheet {
  static Future<void> show({
    required BuildContext context,

    // texts
    required String headerText,
    required String titleText,
    required String negativeText,
    required String positiveText,

    // actions
    required VoidCallback onNegativeTap,
    required VoidCallback onPositiveTap,

    // optional
    double height = 220,
    bool dismissible = true,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: dismissible,
      enableDrag: false,
      showDragHandle: false,
      isScrollControlled: true,
      backgroundColor: Constants.backgroundcolor,
      builder: (BuildContext ctx) {
        return Container(
          padding: const EdgeInsets.all(15),
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            // crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 5),

              // drag indicator
              Container(
                width: 40,
                height: 1.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Constants.maintextColor,
                ),
              ),

              const SizedBox(height: 10),

              // header
              Text(
                headerText.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Constants.FS18,
                  color: Constants.maintextColor,
                ),
              ),

              const SizedBox(height: 20),

              // title
              Text(
                titleText.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Constants.FS10,
                  color: Constants.maintextColor,
                ),
              ),

              const SizedBox(height: 15),

              // buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        onNegativeTap();
                      },
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            negativeText.tr,
                            style: TextStyle(
                              color: Constants.maintextColor,
                              fontSize: Constants.FS12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        onPositiveTap();
                      },
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: headerText == "logoutmsg".tr
                              ? Constants.mainred
                              : Constants.mainblue,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            positiveText.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Constants.maintextColor,
                              fontSize: Constants.FS12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
