import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../presentation/pages/home_page.dart';

class MemoryGameApp extends StatefulWidget {
  const MemoryGameApp({super.key});

  @override
  State<MemoryGameApp> createState() => _MemoryGameAppState();
}

class _MemoryGameAppState extends State<MemoryGameApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _setDarkMode(bool enabled) {
    setState(() {
      _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memoria Animal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: HomePage(onThemeModeChanged: _setDarkMode),
    );
  }
}
