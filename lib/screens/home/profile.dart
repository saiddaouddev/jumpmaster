import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jumpmaster/core/Constants.dart';
import 'package:jumpmaster/services/apiService.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFirstLoad = true;
  String username = "";
  String avatar = "";
  String fullname = "";
  String displayname = "";
  String email = "";
  String address = "";
  String phone = "";
  bool settings = false;

  XFile? selectedImage;
  final ImagePicker imagePicker = ImagePicker();

  Future<void> changeAvatar() async { 
    final XFile? picked =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;
 
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'editphoto'.tr,
          toolbarColor: Constants.backgroundcolor,
          toolbarWidgetColor: Constants.maintextColor,
          backgroundColor: Constants.backgroundcolor,
          activeControlsWidgetColor: Constants.mainblue,
          hideBottomControls: true,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'editphoto'.tr,
          aspectRatioLockEnabled: true,
          rotateButtonsHidden: true,
          hidesNavigationBar: true,
          resetButtonHidden: true,
        ),
      ],
    );

    if (croppedFile == null) return; 
    setState(() {
      selectedImage = XFile(croppedFile.path);
    });
 
    final Map<String, dynamic> data = await ApiService.callApi(
      api: "profile/avatar",
      method: "MULTIPART",
      imageFile: selectedImage,
    );
 
    if (data["success"] == true) {
      setState(() {
        avatar = "${Constants.baseUrl}${data["avatar"]}"; 
      });
 
      Constants.profileCompletion.value =
          data["profile_completion"] ?? Constants.profileCompletion.value;
    }
  }

  @override
  void initState() {
    super.initState();
    getMe();
  }

  bool loading = false;
  Future<void> getMe() async {
    if (isFirstLoad) {
      setState(() {
        loading = true;
      });
    }
    final Map<String, dynamic> data =
        await ApiService.callApi(api: "me", method: "GET");

    if (data["success"] == true) {
      setState(() {
        loading = false;
        username = data["user"]["username"] ?? "";
        avatar = "http://192.168.1.103:8000" + data["user"]["avatar"] ?? ""; 
        fullname = data["user"]["full_name"] ?? "";
        displayname = data["user"]["name"] ?? "";
        email = data["user"]["email"] ?? "";
        phone = data["user"]["phone"] ?? "";
        address = data["user"]["address"] ?? "";
        Constants.profileCompletion.value = data["profile_completion"] ?? 0;
        isFirstLoad = false;
      });
    }
  }

  Future<void> updateMe(String field, String value) async {
    final Map<String, dynamic> data = await ApiService.callApi(
        api: "profile/update", method: "POST", data: {"$field": value});

    if (data["success"] == true) {
      getMe();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Constants.backgroundcolor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                /// PROFILE HEADER
                loading
                    ? SizedBox(
                        height: 123,
                      )
                    : SizedBox(height: 123, child: _profileHeader()),

                const SizedBox(height: 25),

                /// TABS
                _tabs(),

                const SizedBox(height: 15),

                /// TAB CONTENT
                Expanded(
                  child: _tabViews(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= PROFILE HEADER =================

  Widget _profileHeader() {
    return AnimatedAlign(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      alignment: settings ? Alignment.topLeft : Alignment.center,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        width: settings ? 60 : Constants.sw / 4,
        child: Column(
          children: [
            GestureDetector(
              onTap: changeAvatar,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: selectedImage != null
                        ? Image.file(
                            File(selectedImage!.path),
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          )
                        : Image(
                            image: avatar.isEmpty
                                ? const AssetImage("assets/noprofile.jpg")
                                : NetworkImage(avatar) as ImageProvider,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        // width: 20,
                        // height: 20,
                        decoration: BoxDecoration(
                            color: Constants.mainblue, shape: BoxShape.circle),
                        child: Icon(Icons.edit,
                            size: 18, color: Constants.maintextColor),
                      ))
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              displayname.isEmpty ? username : displayname,
              style: TextStyle(
                color: Constants.maintextColor,
                fontWeight: FontWeight.bold,
                fontSize: Constants.FS16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TABS =================

  Widget _tabs() {
    return Container(
      width: Constants.sw,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        dividerColor: Colors.transparent, // ❌ remove default bottom line
        indicatorSize: TabBarIndicatorSize.tab,

        /// 👇 Blue underline only for selected tab
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 3,
            color: Constants.mainblue, // your blue color
          ),
          insets: EdgeInsets.symmetric(horizontal: 5),
        ),

        labelColor: Constants.maintextColor,
        unselectedLabelColor: Constants.maintextColor.withOpacity(0.6),

        tabs: [
          Tab(text: "basicinfo".tr),
          Tab(text: "workouts".tr),
          Tab(text: "history".tr),
          Tab(text: "settings".tr),
        ],
      ),
    );
  }

  // ================= TAB VIEWS =================

  Widget _tabViews() {
    return TabBarView(
      children: [
        /// BASIC INFO
        ListView(
          children: [
            profiletile("phone".tr, phone, Icons.phone, showArrow: false),
            profiletile(
              "fullname".tr,
              fullname.isEmpty ? "taptoadd".tr : fullname,
              Icons.person,
              onTap: () {
                _editField(
                  title: "fullname".tr,
                  initialValue: fullname,
                  fieldKey: "full_name",
                );
              },
            ),
            profiletile(
              "displayname".tr,
              displayname.isEmpty ? "taptoadd".tr : displayname,
              Icons.leaderboard_rounded,
              onTap: () {
                _editField(
                  title: "displayname".tr,
                  initialValue: displayname,
                  fieldKey: "name",
                );
              },
            ),
            profiletile(
                "email".tr, email.isEmpty ? "taptoadd".tr : email, Icons.email,
                onTap: () {
              _editField(
                title: "email".tr,
                initialValue: email,
                fieldKey: "email",
              );
            }),
            profiletile("address".tr, address.isEmpty ? "taptoadd".tr : address,
                Icons.map, onTap: () {
              _editField(
                title: "address".tr,
                initialValue: address,
                fieldKey: "address",
              );
            }),
            profiletile("logout".tr, "logoutaccount".tr, Icons.logout,
                showArrow: false),
          ],
        ),

        /// WORKOUTS
        Center(
          child: Text(
            "Workouts Section",
            style: TextStyle(color: Constants.maintextColor),
          ),
        ),

        /// HISTORY
        Center(
          child: Text(
            "Workout History",
            style: TextStyle(color: Constants.maintextColor),
          ),
        ),

        /// SETTINGS
        ListView(
          children: [],
        ),
      ],
    );
  }

  // ================= PROFILE TILE =================

  Widget profiletile(
    String title,
    String subtitle,
    IconData? icondata, {
    bool showArrow = true,
    VoidCallback? onTap,
  }) {
    final bool simpleMode =
        (subtitle.isEmpty || subtitle.trim().isEmpty) && icondata == null;

    if (simpleMode) {
      return ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: Constants.maintextColor,
            fontSize: Constants.FS16,
          ),
        ),
        trailing: showArrow
            ? Icon(
                Icons.arrow_forward_ios,
                color: Constants.maintextColor.withOpacity(0.7),
                size: 18,
              )
            : null,
      );
    }

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          icondata,
          color: Constants.maintextColor,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(color: Constants.maintextColor),
      ),
      subtitle: subtitle.isEmpty
          ? null
          : Text(
              subtitle,
              style: TextStyle(
                color: Constants.maintextColor.withOpacity(0.6),
              ),
            ),
      trailing: showArrow
          ? Icon(
              Icons.arrow_forward_ios,
              color: Constants.maintextColor.withOpacity(0.7),
              size: 18,
            )
          : null,
    );
  }

  void _editField({
    required String title,
    required String fieldKey,
    required String initialValue,
  }) {
    final TextEditingController controller =
        TextEditingController(text: initialValue);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Constants.backgroundcolor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: Constants.FS16,
                  fontWeight: FontWeight.bold,
                  color: Constants.maintextColor,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: controller,
                style: TextStyle(color: Constants.maintextColor),
                decoration: InputDecoration(
                  hintText: "taptoadd".tr,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.07),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "cancel".tr,
                        style: TextStyle(
                            color: Constants.maintextColor,
                            fontSize: Constants.FS16),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.mainblue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        updateMe(fieldKey, controller.text);
                        Navigator.pop(context);
                      },
                      child: Text(
                        "save".tr,
                        style: TextStyle(
                            color: Constants.maintextColor,
                            fontSize: Constants.FS16),
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
