import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpmaster/core/Constants.dart';
import 'package:jumpmaster/core/storage.dart';
import 'package:jumpmaster/screens/home/landingpage.dart';
import 'package:jumpmaster/services/apiService.dart';
import 'package:jumpmaster/widgets/buttons/main_button.dart';
import 'package:pinput/pinput.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool mobilephone = true;
  bool otp = false;
  String otpCode = "";
  bool loading_resend_otp = false;
  bool loading = false;
  bool loggingIn = false;
  String phone = "";
  TextEditingController phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
        backgroundColor: Constants.backgroundcolor,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.all(10),
                child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: mobilephone
                        ? otp
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AnimatedAlign(
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: 16,
                                        top: topPadding + 8,
                                      ),
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
                                        curve: Curves.easeInOut,
                                        width: 60,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: Image.asset("assets/logo.png"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          textAlign: TextAlign.center,
                                          "verificationotpundertitle".tr,
                                          style: TextStyle(
                                            color: Constants.maintextColor
                                                .withOpacity(0.6),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          textAlign: TextAlign.center,
                                          "961".tr + phone,
                                          style: TextStyle(
                                            color: Constants.maintextColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  Pinput(
                                    length: 6,
                                    defaultPinTheme: PinTheme(
                                      width: 48,
                                      height: 56,
                                      textStyle: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        border: Border.all(
                                          width: 2,
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(14)),
                                      ),
                                    ),
                                    onCompleted: (value) {
                                      otpCode = value;
                                      verifyOTP(phone);
                                    },
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  loading
                                      ? CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          color: Constants.mainblue,
                                        )
                                      : GestureDetector(
                                          onTap: () {},
                                          child: loading_resend_otp
                                              ? Container(
                                                  margin: EdgeInsets.all(10),
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Constants
                                                          .maintextColor,
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  padding: EdgeInsets.all(15),
                                                  child: Text(
                                                    "resendcode".tr,
                                                    style: TextStyle(
                                                      color: Constants
                                                          .maintextColor
                                                          .withOpacity(0.7),
                                                    ),
                                                  ),
                                                ),
                                        ),
                                  SizedBox(height: 10),
                                  Text(
                                    "didntreceivethecode".tr,
                                    style: TextStyle(
                                      color: Constants.maintextColor
                                          .withOpacity(0.5),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        otp = false;
                                      });
                                    },
                                    child: Text(
                                      "trydifferentnumber".tr,
                                      style: TextStyle(
                                        color: Constants.maintextColor
                                            .withOpacity(0.8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : loggingIn
                                ? Center(
                                    child: Container(
                                      width: 200,
                                      height: 200,
                                      child: Column(
                                        children: [
                                          CircularProgressIndicator(
                                              color: Constants.maintextColor),
                                        ],
                                      ),
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      AnimatedAlign(
                                        duration: Duration(milliseconds: 100),
                                        curve: Curves.easeInOut,
                                        alignment: keyboardOpen
                                            ? Alignment.topLeft
                                            : Alignment.center,
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 100),
                                          curve: Curves.easeInOut,
                                          width: keyboardOpen
                                              ? 60
                                              : Constants.sw / 2.2,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child:
                                                Image.asset("assets/logo.png"),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Text(
                                        pref.read("isfirsttime") == null
                                            ? "entermobilenumbertocreateaccount"
                                                .tr
                                            : "welcomeback".tr,
                                        style: TextStyle(
                                          color: Constants.maintextColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 36,
                                        ),
                                      ),
                                      Text(
                                        pref.read("isfirsttime") == null
                                            ? ""
                                            : "signintocontinue".tr,
                                        style: TextStyle(
                                          color: Constants.maintextColor
                                              .withOpacity(0.5),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 30),
                                      Container(
                                        width: Constants.sw,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 0),
                                        child: Text(
                                          textAlign: TextAlign.start,
                                          "phonenumber".tr,
                                          style: TextStyle(
                                            color: Constants.maintextColor
                                                .withOpacity(0.5),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 5),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1,
                                            color: Constants.maintextColor
                                                .withOpacity(0.7),
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12)),
                                        ),
                                        child: Row(
                                          textDirection: TextDirection.ltr,
                                          children: [
                                            SizedBox(width: 10),
                                            Image.asset("assets/phoneicon.png",
                                                color: Constants.mainblue,
                                                width: 20),
                                            Container(
                                              margin: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                      color: Colors.black,
                                                      width: 1),
                                                ),
                                              ),
                                              width: 60,
                                              height: 50,
                                              child: Center(
                                                child: Text(
                                                  "961".tr,
                                                  textDirection:
                                                      TextDirection.ltr,
                                                  style: TextStyle(
                                                    color:
                                                        Constants.maintextColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                // width: 180,
                                                margin:
                                                    EdgeInsets.only(right: 20),
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0, 0, 0),
                                                child: TextFormField(
                                                  enabled:
                                                      loading ? false : true,
                                                  maxLength: 8,
                                                  textAlign: TextAlign.start,
                                                  controller: phoneController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  style: TextStyle(
                                                    color:
                                                        Constants.maintextColor,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            left: 5),
                                                    counterText: "",
                                                    errorStyle:
                                                        TextStyle(height: 0),
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    hintStyle: TextStyle(
                                                      color: Constants
                                                          .maintextColor
                                                          .withOpacity(0.4),
                                                    ),
                                                    hintText: "3 456789",
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          loading
                                              ? CircularProgressIndicator(
                                                  strokeWidth: 1.5,
                                                  color: Constants.mainblue,
                                                )
                                              : InkWell(
                                                  onTap: () {
                                                    phone =
                                                        phoneController.text;
                                                    requestOTP(phone);
                                                  },
                                                  child: Container(
                                                    child: MainButton(
                                                        str: "signin".tr),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ],
                                  )
                        : Container()))));
  }

  void requestOTP(String phone) async {
    setState(() {
      loading = true;
    });

    var data = await ApiService.callApi(
      api: "auth/request-otp",
      method: "POST",
      data: {"phone": "+961" + phoneController.text},
    );

    if (data["success"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["message"] + " " + data["dev_otp"].toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        otp = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["message"] ?? "somethingwentwrong".tr),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    // finally {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text("Servernotresponding".tr),
    //         behavior: SnackBarBehavior.floating,
    //       ),
    //     );
    //     setState(() {
    //       loading = false;
    //     });
    //   }
    // }
    setState(() {
      loading = false;
    });
  }

  void verifyOTP(String phone) async {
    setState(() {
      loading = true;
    });

    var data = await ApiService.callApi(
      api: "auth/verify-otp",
      method: "POST",
      data: {
        "phone": "+961$phone",
        "otp": otpCode,
      },
    );

    if (data["success"] == true) {
      pref.write("phone", data["user"]["phone"]);
      pref.write("token", data["token"]);
      context.go('/home');

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => HomePage()),
      // );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data["message"] ?? "somethingwentwrong".tr,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    //  finally {
    //   if (mounted) {

    //   }
    // }
    setState(() {
      otp = false;
      loading = false;
    });
  }
}
