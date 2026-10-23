// lib/services/alarm_service.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class AlarmService {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> startAlarm() async {
    if (_isPlaying) return;
    _isPlaying = true;

    try {
      final canVibrate = await Vibration.hasVibrator();
      if (canVibrate == true) {
        Vibration.vibrate(pattern: [0, 500, 500, 500, 500, 500], repeat: 0);
      }
    } catch (_) {}

    try {
      await _player.setVolume(1.0);
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('sounds/emergency.ogg'));
    } catch (_) {
      _isPlaying = false;
    }
  }

  Future<void> stopAlarm() async {
    _isPlaying = false;

    try {
      await _player.stop();
    } catch (_) {}

    try {
      Vibration.cancel();
    } catch (_) {}
  }

  Future<void> playAlarmForDuration(Duration duration) async {
    await startAlarm();
    await Future.delayed(duration);
    await stopAlarm();
  }

  void dispose() {
    stopAlarm();
    try {
      _player.dispose();
    } catch (_) {}
  }
}
