import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _create(AppColors.light, Brightness.light);

  static ThemeData get dark => _create(AppColors.dark, Brightness.dark);

  static ThemeData _create(AppPalette palette, Brightness brightness) {
    final baseTextTheme = ThemeData(brightness: brightness).textTheme
        .apply(bodyColor: palette.textDark, displayColor: palette.textDark);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: palette.primaryDark,
            brightness: brightness,
          ).copyWith(
            primary: palette.primaryDark,
            onPrimary: Colors.white,
            secondary: palette.secondary,
            surface: palette.panel,
            onSurface: palette.textDark,
            error: palette.mismatch,
            tertiary: palette.playfulMint,
          ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: const TextStyle(fontWeight: FontWeight.w900),
        headlineMedium: const TextStyle(fontWeight: FontWeight.w900),
        titleLarge: const TextStyle(fontWeight: FontWeight.w800),
        titleMedium: const TextStyle(fontWeight: FontWeight.w800),
        bodyLarge: const TextStyle(fontWeight: FontWeight.w600),
        bodyMedium: const TextStyle(fontWeight: FontWeight.w600),
      ),
      iconTheme: IconThemeData(color: palette.textDark, size: 22),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: palette.primaryDark.withValues(alpha: 0.22),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.textDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.panel,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: TextStyle(
          color: palette.textDark,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
        contentTextStyle: TextStyle(
          color: palette.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.panel,
        contentTextStyle: TextStyle(
          color: palette.textDark,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.panel,
        modalBackgroundColor: palette.panel,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: palette.textDark,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(10),
        ),
      ),
    );
  }
}
