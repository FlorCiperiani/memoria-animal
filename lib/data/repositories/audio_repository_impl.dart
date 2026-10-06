import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/repositories/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  AudioRepositoryImpl({
    AudioPlayer? ambientPlayer,
    AudioPlayer? effectPlayer,
    AudioPlayer? victoryPlayer,
  }) : _ambientPlayer = ambientPlayer ?? AudioPlayer(),
       _effectPlayer = effectPlayer ?? AudioPlayer(),
       _victoryPlayer = victoryPlayer ?? AudioPlayer();

  static const _dayTheme = 'audio/sonido_dia.mp3';
  static const _nightTheme = 'audio/sonido_noche.mp3';
  static const _correctEffect = 'audio/correcto.mp3';
  static const _incorrectEffect = 'audio/incorrecto.mp3';
  static const _victoryEffect = 'audio/sonido_ganador.mp3';
  static const _ambientVolume = 0.12;
  static const _effectVolume = 0.55;
  static final _ambientAudioContext = AudioContext(
    android: const AudioContextAndroid(
      usageType: AndroidUsageType.game,
      contentType: AndroidContentType.music,
      audioFocus: AndroidAudioFocus.none,
    ),
  );
  static final _effectAudioContext = AudioContext(
    android: const AudioContextAndroid(
      usageType: AndroidUsageType.game,
      contentType: AndroidContentType.sonification,
      audioFocus: AndroidAudioFocus.none,
    ),
  );

  final AudioPlayer _ambientPlayer;
  final AudioPlayer _effectPlayer;
  final AudioPlayer _victoryPlayer;

  Future<void> _ambientQueue = Future<void>.value();
  Future<void> _victoryQueue = Future<void>.value();
  bool? _isDark;
  bool _isPaused = false;
  bool _ambientStarted = false;
  bool _ambientEnabled = true;
  bool _effectsEnabled = true;
  bool _isDisposed = false;

  @override
  Future<void> playThemeAmbient({required bool isDark}) {
    return _enqueueAmbient(() async {
      if (_isDisposed) return;
      if (!_ambientEnabled) {
        _isDark = isDark;
        return;
      }
      if (_ambientStarted && _isDark == isDark && !_isPaused) return;

      _isDark = isDark;
      _isPaused = false;
      _ambientStarted = true;
      await _ambientPlayer.setAudioContext(_ambientAudioContext);
      await _ambientPlayer.stop();
      await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
      await _ambientPlayer.setVolume(_ambientVolume);
      await _ambientPlayer.play(AssetSource(isDark ? _nightTheme : _dayTheme));
    });
  }

  @override
  Future<void> pauseThemeAmbient() {
    return _enqueueAmbient(() async {
      if (_isDisposed || !_ambientStarted || _isPaused) return;
      await _ambientPlayer.pause();
      _isPaused = true;
    });
  }

  @override
  Future<void> resumeThemeAmbient() {
    return _enqueueAmbient(() async {
      if (_isDisposed || !_ambientEnabled || !_ambientStarted || !_isPaused) {
        return;
      }
      await _ambientPlayer.resume();
      _isPaused = false;
    });
  }

  @override
  Future<void> setAmbientEnabled(bool enabled) async {
    if (_isDisposed || _ambientEnabled == enabled) return;
    _ambientEnabled = enabled;
    if (!enabled) {
      await stopVictory();
      await _enqueueAmbient(() async {
        if (!_ambientStarted || _isPaused) return;
        await _ambientPlayer.stop();
        _isPaused = true;
      });
    } else {
      await playThemeAmbient(isDark: _isDark ?? false);
    }
  }

  @override
  Future<void> setEffectsEnabled(bool enabled) async {
    _effectsEnabled = enabled;
  }

  @override
  Future<void> playCorrectPair() => _playEffect(_correctEffect);

  @override
  Future<void> playIncorrectPair() => _playEffect(_incorrectEffect);

  @override
  Future<void> playVictory() async {
    if (_isDisposed || !_ambientEnabled) return;
    await _enqueueVictory(() async {
      if (_isDisposed || !_ambientEnabled) return;
      await _victoryPlayer.setAudioContext(_effectAudioContext);
      await _victoryPlayer.setVolume(_effectVolume);
      await _victoryPlayer.play(AssetSource(_victoryEffect));
    });
  }

  @override
  Future<void> stopVictory() async {
    if (_isDisposed) return;
    await _enqueueVictory(_victoryPlayer.stop);
  }

  Future<void> _playEffect(String asset) async {
    if (_isDisposed || !_effectsEnabled) return;
    await _runAudioOperation(() async {
      await _effectPlayer.setAudioContext(_effectAudioContext);
      await _effectPlayer.setVolume(_effectVolume);
      await _effectPlayer.play(AssetSource(asset));
    });
  }

  Future<void> _enqueueAmbient(Future<void> Function() operation) {
    final queued = _ambientQueue.then((_) => _runAudioOperation(operation));
    _ambientQueue = queued;
    return queued;
  }

  Future<void> _enqueueVictory(Future<void> Function() operation) {
    final queued = _victoryQueue.then((_) => _runAudioOperation(operation));
    _victoryQueue = queued;
    return queued;
  }

  Future<void> _runAudioOperation(Future<void> Function() operation) async {
    try {
      await operation();
    } on AudioPlayerException catch (error, stackTrace) {
      _reportAudioError(error, stackTrace);
    } on PlatformException catch (error, stackTrace) {
      _reportAudioError(error, stackTrace);
    }
  }

  void _reportAudioError(Object error, StackTrace stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'application audio',
        context: ErrorDescription('while playing an audio asset'),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _ambientQueue;
    await _victoryQueue;
    await _runAudioOperation(_ambientPlayer.dispose);
    await _runAudioOperation(_effectPlayer.dispose);
    await _runAudioOperation(_victoryPlayer.dispose);
  }
}
