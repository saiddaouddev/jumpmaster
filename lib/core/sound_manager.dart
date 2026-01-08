import 'package:audioplayers/audioplayers.dart';
import 'package:get_storage/get_storage.dart'; 

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;

  SoundManager._internal();

  final AudioPlayer _player = AudioPlayer();
  final pref = GetStorage();

  static const String _key = "sound_enabled";

  bool get isEnabled => pref.read(_key) ?? true;

  void setEnabled(bool value) {
    pref.write(_key, value);
  }

  Future<void> play(String assetPath) async {
    if (!isEnabled) return;

    await _player.play(
      AssetSource(assetPath),
      volume: 1.0,
    );
  }

  Future<void> stop() async {
    await _player.stop();
  }
}
