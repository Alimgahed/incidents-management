// lib/services/alarm_service.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

class AlarmService {
  AudioPlayer? _player;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  AudioPlayer _getOrCreatePlayer() {
    if (_player == null) {
      _player = AudioPlayer();
    }
    return _player!;
  }

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
      final player = _getOrCreatePlayer();
      await player.stop();
      await player.setVolume(1.0);
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource('sounds/emergency.ogg'));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AlarmService startAlarm error: $e');
      }
      // Re-create player on error to recover from any corrupted state
      _disposePlayer();
      try {
        final player = _getOrCreatePlayer();
        await player.setVolume(1.0);
        await player.setReleaseMode(ReleaseMode.loop);
        await player.play(AssetSource('sounds/emergency.ogg'));
      } catch (retryError) {
        if (kDebugMode) {
          debugPrint('AlarmService retry failed: $retryError');
        }
        _isPlaying = false;
      }
    }
  }

  Future<void> stopAlarm() async {
    _isPlaying = false;

    try {
      await _player?.stop();
    } catch (_) {}

    try {
      await Vibration.cancel();
    } catch (_) {}
  }

  Future<void> playAlarmForDuration(Duration duration) async {
    await startAlarm();
    await Future.delayed(duration);
    await stopAlarm();
  }

  void _disposePlayer() {
    try {
      _player?.dispose();
    } catch (_) {}
    _player = null;
  }

  void dispose() {
    stopAlarm();
    _disposePlayer();
  }
}

