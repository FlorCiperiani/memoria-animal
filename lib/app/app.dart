import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../domain/repositories/audio_repository.dart';
import '../domain/repositories/game_profile_repository.dart';
import '../presentation/pages/home_page.dart';
import 'injection.dart';

class MemoryGameApp extends StatefulWidget {
  const MemoryGameApp({super.key});

  @override
  State<MemoryGameApp> createState() => _MemoryGameAppState();
}

class _MemoryGameAppState extends State<MemoryGameApp>
    with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.light;

  AudioRepository get _audioRepository => sl<AudioRepository>();
  GameProfileRepository get _profileRepository => sl<GameProfileRepository>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _setDarkMode(bool enabled) {
    setState(() {
      _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    });
    unawaited(_audioRepository.playThemeAmbient(isDark: enabled));
  }

  void _startThemeAmbient() {
    unawaited(_startThemeAmbientAsync());
  }

  Future<void> _startThemeAmbientAsync() async {
    try {
      final enabled = await _profileRepository.loadAmbientEnabled();
      await _audioRepository.setAmbientEnabled(enabled);
      unawaited(
        _audioRepository.playThemeAmbient(isDark: _themeMode == ThemeMode.dark),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'application audio',
          context: ErrorDescription('while starting the theme ambience'),
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_audioRepository.resumeThemeAmbient());
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_audioRepository.pauseThemeAmbient());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_audioRepository.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memoria Animal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: HomePage(
        onThemeModeChanged: _setDarkMode,
        onStartAmbient: _startThemeAmbient,
        profileRepository: _profileRepository,
      ),
    );
  }
}
