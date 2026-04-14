// lib/services/alarm_service.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class AlarmService {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  Future<void> startAlarm() async {
    if (_isPlaying) return;
    _isPlaying = true;

    // Continuous vibration pattern: 500 ms on, 500 ms off
    final canVibrate = await Vibration.hasVibrator();
    if (canVibrate) {
      Vibration.vibrate(pattern: [0, 500, 500, 500, 500, 500], repeat: 0);
    }

    // Play alarm sound on loop
    // Place an alarm.mp3 file in assets/sounds/
    await _player.setVolume(1.0);
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('sounds/alarm.ogg'));
  }

  Future<void> stopAlarm() async {
    if (!_isPlaying) return;
    _isPlaying = false;

    await _player.stop();
    Vibration.cancel();
  }

  void dispose() {
    _player.dispose();
  }
}
