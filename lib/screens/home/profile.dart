import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jumpmaster/core/Constants.dart';
import 'package:jumpmaster/core/enums/setting_tile_type.dart';
import 'package:jumpmaster/core/sound_manager.dart';
import 'package:jumpmaster/core/storage.dart';
import 'package:jumpmaster/core/vibration_manager.dart';
import 'package:jumpmaster/models/achievements.dart';
import 'package:jumpmaster/models/workout.dart';
import 'package:jumpmaster/services/apiService.dart';
import 'package:jumpmaster/utils/bottomsheet.dart';
import 'package:jumpmaster/utils/profile_avatar_viewer.dart';
import 'package:jumpmaster/widgets/cards/AchievementTrainItem.dart';
import 'package:jumpmaster/widgets/cards/shareWorkoutCard.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with WidgetsBindingObserver {
  List<Achievement> achievementsList = [];
  final ScreenshotController controller = ScreenshotController();

  // bool notificationsEnabled = true;
  String appversion = "";
  String SOUND_ENABLED_KEY = "sound_enabled";
  String VIBRATION_ENABLED_KEY = "vibration_enabled";
  bool soundEnabled = true;
  bool vibrationEnabled = false;
  double fontSize = 1; // Medium
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
  Future<void> onSavePressed(String jumps, int sec, String cal) async {
    try {
      final bytes = await controller.captureFromWidget(
        Material(
          type: MaterialType.transparency,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ShareWorkoutCard(
              jumps: jumps,
              timeSeconds: sec,
              calories: cal,
            ),
          ),
        ),
        pixelRatio: 3,
      );

      if (bytes == null) return;

      await saveToGallery(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved to gallery")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save image")),
      );
    }
  }

  void updateFontSize(double sliderValue) {
    double scale;
    switch (sliderValue.toInt()) {
      case 0:
        scale = 0.5; //0.85; // Small
        break;
      case 2:
        scale = 1.2; // Large
        break;
      default:
        scale = 1.0; // Medium
    }

    Constants.updateFontScale(scale);
    pref.write("font_scale", sliderValue);

    setState(() {
      fontSize = sliderValue;
    });
    Get.forceAppUpdate();
  }

  Future<void> saveToGallery(Uint8List bytes) async {
    await Gal.putImageBytes(
      bytes,
      album: "Jump Master",
      name: "jump_master_${DateTime.now().millisecondsSinceEpoch}.png",
    );
  }

  Future<void> toggleVibration(bool enabled) async {
    VibrationManager().setEnabled(enabled);

    setState(() {
      vibrationEnabled = enabled;
    });
  }

  void initSoundSetting() {
    bool enabled = pref.read(SOUND_ENABLED_KEY) ?? true;
    bool vib_enabled = pref.read(VIBRATION_ENABLED_KEY) ?? true;

    setState(() {
      soundEnabled = enabled;
      vibrationEnabled = vib_enabled;
    });
  }

  Future<void> toggleSound(bool enabled) async {
    SoundManager().setEnabled(enabled);

    setState(() {
      soundEnabled = enabled;
    });
  }

  Future<void> shareWorkout(String jumps, int sec, String cal) async {
    final image = await controller.captureFromWidget(
      Material(
          type: MaterialType.transparency, // 🔥 critical
          child: Directionality(
              textDirection: TextDirection.ltr,
              child: ShareWorkoutCard(
                jumps: jumps,
                timeSeconds: sec,
                calories: cal,
              ))),
      pixelRatio: 3,
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/jump_master.png");
    await file.writeAsBytes(image);

    Share.shareXFiles(
      [XFile(file.path)],
      text: "Just smashed my jump rope workout 💪🔥",
    );
  }

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log(state.toString());
    if (state == AppLifecycleState.paused) {
    } else if (state == AppLifecycleState.resumed) {
      checkNotificationPermission();
    }
  }

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      appversion = packageInfo.version;
    });
    WidgetsBinding.instance.addObserver(this);
    fontSize = pref.read("font_scale") ?? 1.0;
    updateFontSize(fontSize);
    checkNotificationPermission();
    initSoundSetting();
    getMe();
    getWorkouts();
    getAchievements();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !isMoreLoading &&
          currentPage < lastPage) {
        currentPage++;
        getWorkouts(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool loading = false;
  List<Workout> workouts = [];

  bool isLoading = false;
  bool isMoreLoading = false;

  int currentPage = 1;
  int lastPage = 1;

  final ScrollController scrollController = ScrollController();

  Future<void> getAchievements() async {
    final Map<String, dynamic> data = await ApiService.callApi(
      api: "achievements",
      method: "GET",
    );

    if (data["success"] == true) {
      final List list = data["data"];

      achievementsList = list.map((e) => Achievement.fromJson(e)).toList();
    }
  }

  Future<void> getWorkouts({bool loadMore = false}) async {
    if (loadMore) {
      isMoreLoading = true;
    } else {
      isLoading = true;
      currentPage = 1;
      workouts.clear();
    }

    setState(() {});

    final Map<String, dynamic> data = await ApiService.callApi(
      api: "me/workouts?page=$currentPage",
      method: "GET",
    );

    if (data["success"] == true) {
      final response = data["data"];

      currentPage = response["current_page"];
      lastPage = response["last_page"];

      final List list = response["data"];

      workouts.addAll(
        list.map((e) => Workout.fromJson(e)).toList(),
      );
    }

    isLoading = false;
    isMoreLoading = false;
    setState(() {});
  }

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
        avatar = data["user"]["avatar"] != null
            ? "http://10.10.10.23:8000${data["user"]["avatar"]}"
            : "";
        fullname = data["user"]["full_name"] ?? "";
        displayname = data["user"]["name"] ?? "";
        email = data["user"]["email"] ?? "";
        phone = data["user"]["phone"] ?? "";
        address = data["user"]["address"] ?? "";
        Constants.profileCompletion.value = data["profile_completion"] ?? 0;
      });
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        isFirstLoad = false;
      });
    });
  }

  Future<void> updateMe(String field, String value) async {
    final Map<String, dynamic> data = await ApiService.callApi(
        api: "profile/update", method: "POST", data: {"$field": value});

    if (data["success"] == true) {
      getMe();
    }
  }

  void logout() async {
    var data = await ApiService.callApi(
      api: "auth/logout",
      method: "POST",
    );

    if (!mounted) return; // 🔑 VERY IMPORTANT

    if (data["success"] == true) {
      pref.write("token", null);
      pref.write("phone", null);
      context.go('/auth');
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
                    : _profileHeader(),

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
            Stack(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          opaque: false,
                          barrierColor: Colors.black,
                          pageBuilder: (_, __, ___) => ProfileImageViewer(
                            heroTag: 'profile-avatar',
                            imageProvider: selectedImage != null
                                ? FileImage(File(selectedImage!.path))
                                : (avatar.isEmpty
                                    ? const AssetImage("assets/noprofile.jpg")
                                    : NetworkImage(avatar)) as ImageProvider,
                          ),
                        ),
                      );
                    },
                    child: Hero(
                        tag: 'profile-avatar',
                        child: ClipRRect(
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
                        ))),
                GestureDetector(
                    onTap: changeAvatar,
                    child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: EdgeInsets.all(5),
                          // width: 20,
                          // height: 20,
                          decoration: BoxDecoration(
                              color: Constants.mainblue,
                              shape: BoxShape.circle),
                          child: Icon(Icons.edit,
                              size: 18, color: Constants.maintextColor),
                        )))
              ],
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
        color: Constants.maintextColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        labelStyle: TextStyle(fontSize: Constants.FS14),
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
          Tab(text: "badges".tr),
          Tab(text: "settings".tr),
        ],
      ),
    );
  }

  // ================= TAB VIEWS =================

  Widget _tabViews() {
    return TabBarView(
      physics: const NeverScrollableScrollPhysics(),
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
            GestureDetector(
                onTap: () {
                  AppConfirmSheet.show(
                    context: context,
                    headerText: "logoutmsg".tr,
                    titleText: "",
                    negativeText: "no".tr,
                    positiveText: "yes".tr,
                    onNegativeTap: () {},
                    onPositiveTap: () {
                      logout();
                    },
                  );
                },
                child: profiletile(
                    "logout".tr, "logoutaccount".tr, Icons.logout,
                    showArrow: false)),
          ],
        ),

        /// WORKOUTS
        workouts.isEmpty
            ? Text("youhavenoworkouts".tr)
            : ListView.builder(
                controller: scrollController,
                itemCount: workouts.length + 1,
                itemBuilder: (context, index) {
                  if (index < workouts.length) {
                    return GestureDetector(
                        onTap: () {
                          AppConfirmSheet.show(
                            context: context,
                            headerText: "shareworkoutmsg".tr,
                            titleText: "",
                            negativeText: "savetogallery".tr,
                            positiveText: "sharetosocials".tr,
                            onNegativeTap: () {
                              onSavePressed(
                                  workouts[index].jumps.toString(),
                                  workouts[index].durationSeconds,
                                  workouts[index].calories.toStringAsFixed(0));
                            },
                            onPositiveTap: () {
                              shareWorkout(
                                  workouts[index].jumps.toString(),
                                  workouts[index].durationSeconds,
                                  workouts[index].calories.toStringAsFixed(0));
                            },
                          );
                          // shareWorkout(
                          //     workouts[index].jumps.toString(),
                          //     workouts[index].durationSeconds,
                          //     workouts[index].calories.toStringAsFixed(0));
                        },
                        child: _workoutTile(workouts[index]));
                  }

                  if (isMoreLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),

        /// HISTORY
        workouts.isEmpty
            ? Text("achievementsnotavailable".tr)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 20),
                itemCount: achievementsList.length,
                itemBuilder: (context, index) {
                  return AchievementTrainItem(
                    index: index,
                    achievement: achievementsList[index],
                    isLast: index == achievementsList.length - 1,
                    previousUnlocked:
                        index > 0 && achievementsList[index - 1].unlocked,
                  );
                },
              ),

        /// SETTINGS
        ListView(
          children: [
            settingsTile(
              title: "notifications".tr,
              subtitle: "receiveworkoutalerts".tr,
              icon: Icons.notifications,
              type: SettingTileType.toggle,
              switchValue: pref.read("allownotification") ?? false,
              onToggle: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("redirectmsgAppSettings".tr),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Future.delayed(Duration(seconds: 3), () {
                  openAppSettings();
                });
              },
            ),
            settingsTile(
              title: "sound".tr,
              subtitle: "appsounds".tr,
              icon: Icons.volume_up,
              type: SettingTileType.toggle,
              switchValue: soundEnabled,
              onToggle: (v) => toggleSound(v),
            ),
            settingsTile(
              title: "vibration".tr,
              subtitle: "hapticfeedback".tr,
              icon: Icons.vibration,
              type: SettingTileType.toggle,
              switchValue: vibrationEnabled,
              onToggle: (v) => toggleVibration(v),
            ),
            fontSizeTile(
              value: fontSize,
              onChanged: (v) => updateFontSize(v),
            ),
            settingsTile(
              title: "findourproducts".tr,
              subtitle: "shopjumpmasteraccessories".tr,
              icon: Icons.shopping_bag_outlined,
              type: SettingTileType.navigation,
              onTap: () {
                launchLink("https://yourstore.com");
              },
            ),

            // Contact support
            settingsTile(
              title: "contactsupport".tr,
              subtitle: "whatsapp".tr,
              icon: Icons.phone,
              type: SettingTileType.navigation,
              onTap: () {
                launchLink("https://wa.me/96170123456");
              },
            ),

            Center(
              child: Text(
                textAlign: TextAlign.center,
                "appversion".tr + "\n$appversion",
                style: TextStyle(
                    color: Constants.maintextColor, fontSize: Constants.FS14),
              ),
            )
          ],
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
          color: Constants.maintextColor.withOpacity(0.07),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          icondata,
          color: Constants.maintextColor,
        ),
      ),
      title: Text(
        title,
        style:
            TextStyle(color: Constants.maintextColor, fontSize: Constants.FS16),
      ),
      subtitle: subtitle.isEmpty
          ? null
          : Text(
              subtitle,
              style: TextStyle(
                fontSize: Constants.FS14,
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
                style: TextStyle(
                    color: Constants.maintextColor, fontSize: Constants.FS14),
                decoration: InputDecoration(
                  hintText: "taptoadd".tr,
                  filled: true,
                  fillColor: Constants.maintextColor.withOpacity(0.07),
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
                        backgroundColor:
                            Constants.maintextColor.withOpacity(0.15),
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

  Widget _workoutTile(Workout workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          // Left: Date
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Constants.mainblue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _dayText(workout.startedAt),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Constants.FS12,
                  fontWeight: FontWeight.bold,
                  color: Constants.mainblue,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Middle: Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.startedAtFormatted.toString(),
                  style: TextStyle(
                    fontSize: Constants.FS12,
                    color: Constants.maintextColor.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${workout.jumps} jumps • ${workout.durationSeconds} sec",
                  style: TextStyle(
                    fontSize: Constants.FS14,
                    fontWeight: FontWeight.w600,
                    color: Constants.maintextColor,
                  ),
                ),
              ],
            ),
          ),

          // Right: Calories
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text(
                  //   "calories".tr,
                  //   style: TextStyle(
                  //     fontSize: 12,
                  //     color: Constants.maintextColor,
                  //   ),
                  // ),
                  // const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.share,
                      size: 18,
                      color: Constants.maintextColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                "${workout.calories.toStringAsFixed(0)} kcal",
                style: TextStyle(
                  fontSize: Constants.FS12,
                  fontWeight: FontWeight.bold,
                  color: Constants.maintextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _dayText(DateTime date) {
    return "${date.day}\n${_month(date.month)}";
  }

  String _month(int m) {
    const months = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC"
    ];
    return months[m - 1];
  }

  Widget settingsTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required SettingTileType type,

    // Toggle
    bool? switchValue,
    ValueChanged<bool>? onToggle,

    // Navigation
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: type == SettingTileType.navigation ? onTap : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: title == "contactsupport".tr
              ? Colors.green
              : Constants.maintextColor.withOpacity(0.07),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon,
            color: title == "contactsupport".tr
                ? Colors.white
                : Constants.maintextColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Constants.maintextColor,
          fontSize: Constants.FS16,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: Constants.FS14,
                color: Constants.maintextColor.withOpacity(0.6),
              ),
            )
          : null,
      trailing: type == SettingTileType.toggle
          ? Switch(
              value: switchValue ?? false,
              onChanged: onToggle,
              activeColor: Constants.mainblue,
            )
          : type == SettingTileType.navigation
              ? Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Constants.maintextColor.withOpacity(0.6),
                )
              : null,
    );
  }

  Widget fontSizeTile({
    required double value, // 0 = Small, 1 = Medium, 2 = Large
    required ValueChanged<double> onChanged,
  }) {
    final labels = ["small".tr, "medium".tr, "large".tr];

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Constants.backgroundcolor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Constants.maintextColor.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.text_fields, color: Constants.maintextColor),
              ),
              const SizedBox(width: 12),
              Text(
                "fontsize".tr,
                style: TextStyle(
                  color: Constants.maintextColor,
                  fontSize: Constants.FS16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: value,
            min: 0,
            max: 2,
            divisions: 2,
            label: labels[value.toInt()],
            activeColor: Constants.mainblue,
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels
                .map(
                  (e) => Text(
                    e,
                    style: TextStyle(
                      color: Constants.maintextColor.withOpacity(0.6),
                      fontSize: Constants.FS12,
                    ),
                  ),
                )
                .toList(),
          )
        ],
      ),
    );
  }

  Future<void> launchLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  bool showNotification = false;
  Future<void> checkNotificationPermission() async {
    bool allowed = false;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      PermissionStatus status = await Permission.notification.status;
      allowed = status.isGranted;
      // log(status.toString());
    } else {
      // iOS handled elsewhere
      PermissionStatus status = await Permission.notification.status;
      allowed = status.isGranted;
    }

    pref.write("allownotification", allowed);
    setState(() {
      showNotification = allowed;
    });
  }
}
