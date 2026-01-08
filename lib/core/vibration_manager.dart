import 'dart:developer';

import 'package:get_storage/get_storage.dart';
import 'package:vibration/vibration.dart';

class VibrationManager {
  static final VibrationManager _instance = VibrationManager._internal();
  factory VibrationManager() => _instance;

  VibrationManager._internal();

  final _storage = GetStorage();
  static const String _key = "vibration_enabled";

  bool get isEnabled => _storage.read(_key) ?? true;

  void setEnabled(bool value) {
    _storage.write(_key, value);
  }

  Future<void> vibrate({
    int duration = 400,
  }) async {
    log(isEnabled.toString());
    if (!isEnabled) return;

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: duration);
    }
  }

  Future<void> vibratePattern() async {
    if (!isEnabled) return;

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(
        pattern: [0, 40, 60, 40],
      );
    }
  }
}
