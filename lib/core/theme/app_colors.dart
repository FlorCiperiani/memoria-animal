import 'package:flutter/material.dart';

import '../../domain/entities/game_style.dart';

class AppPalette {
  const AppPalette({
    required this.backgroundTop,
    required this.background,
    required this.backgroundBottom,
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.secondaryDark,
    required this.playfulBlue,
    required this.playfulMint,
    required this.panel,
    required this.panelBorder,
    required this.cardBack,
    required this.cardFront,
    required this.mismatch,
    required this.mismatchBackground,
    required this.textDark,
    required this.textMedium,
    required this.textLight,
    required this.lavender,
  });

  final Color backgroundTop;
  final Color background;
  final Color backgroundBottom;
  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color secondaryDark;
  final Color playfulBlue;
  final Color playfulMint;
  final Color panel;
  final Color panelBorder;
  final Color cardBack;
  final Color cardFront;
  final Color mismatch;
  final Color mismatchBackground;
  final Color textDark;
  final Color textMedium;
  final Color textLight;
  final Color lavender;
}

class AppColors {
  const AppColors._();

  static const light = AppPalette(
    backgroundTop: Color(0xFFBFE9FF),
    background: Color(0xFFDEF7FF),
    backgroundBottom: Color(0xFFF9D7A2),
    primary: Color(0xFFFF725E),
    primaryDark: Color(0xFFE6534E),
    secondary: Color(0xFFFFC94A),
    secondaryDark: Color(0xFF8B5A00),
    playfulBlue: Color(0xFF5AA9FF),
    playfulMint: Color(0xFF4CC7A5),
    panel: Color(0xFFFFFEF8),
    panelBorder: Color(0xFFC9E7FF),
    cardBack: Color(0xFF2EB7D4),
    cardFront: Color(0xFFFFE69B),
    mismatch: Color(0xFFEF5364),
    mismatchBackground: Color(0xFFFCE1E5),
    textDark: Color(0xFF33415C),
    textMedium: Color(0xFF5D6B82),
    textLight: Color(0xFF8490A2),
    lavender: Color(0xFF9883E8),
  );

  static const dark = AppPalette(
    backgroundTop: Color(0xFF1A2D4D),
    background: Color(0xFF111D37),
    backgroundBottom: Color(0xFF26314F),
    primary: Color(0xFF67D5D0),
    primaryDark: Color(0xFF49BDBB),
    secondary: Color(0xFFFFCB61),
    secondaryDark: Color(0xFFF3BB4D),
    playfulBlue: Color(0xFF8BC0FF),
    playfulMint: Color(0xFF66D9B8),
    panel: Color(0xFF27344D),
    panelBorder: Color(0xFF3E506C),
    cardBack: Color(0xFF176D7D),
    cardFront: Color(0xFF39466C),
    mismatch: Color(0xFFFF7E89),
    mismatchBackground: Color(0xFF533244),
    textDark: Color(0xFFF7F4E9),
    textMedium: Color(0xFFD1D8E5),
    textLight: Color(0xFFAAB6CA),
    lavender: Color(0xFFB19AFF),
  );

  // Desierto (Desert)
  static const _desertLight = AppPalette(
    backgroundTop: Color(0xFFFFD54F),
    background: Color(0xFFFFF8E1),
    backgroundBottom: Color(0xFFFFB74D),
    primary: Color(0xFFE65100),
    primaryDark: Color(0xFFBF360C),
    secondary: Color(0xFFFF8F00),
    secondaryDark: Color(0xFFE65100),
    playfulBlue: Color(0xFF0288D1),
    playfulMint: Color(0xFF388E3C),
    panel: Color(0xFFFFFEF9),
    panelBorder: Color(0xFFFFE082),
    cardBack: Color(0xFFD84315),
    cardFront: Color(0xFFFFECB3),
    mismatch: Color(0xFFD32F2F),
    mismatchBackground: Color(0xFFFFCDD2),
    textDark: Color(0xFF3E2723),
    textMedium: Color(0xFF5D4037),
    textLight: Color(0xFF8D6E63),
    lavender: Color(0xFF7B1FA2),
  );

  static const _desertDark = AppPalette(
    backgroundTop: Color(0xFF1B1A24),
    background: Color(0xFF121118),
    backgroundBottom: Color(0xFF261A16),
    primary: Color(0xFFFFB74D),
    primaryDark: Color(0xFFFFA726),
    secondary: Color(0xFFFFD54F),
    secondaryDark: Color(0xFFFFC107),
    playfulBlue: Color(0xFF4FC3F7),
    playfulMint: Color(0xFF81C784),
    panel: Color(0xFF221F28),
    panelBorder: Color(0xFF3D3230),
    cardBack: Color(0xFFBF360C),
    cardFront: Color(0xFF3B2E2B),
    mismatch: Color(0xFFEF5350),
    mismatchBackground: Color(0xFF5C2D2D),
    textDark: Color(0xFFFBE9E7),
    textMedium: Color(0xFFD7CCC8),
    textLight: Color(0xFFA1887F),
    lavender: Color(0xFFBA68C8),
  );

  // Selva (Jungle)
  static const _jungleLight = AppPalette(
    backgroundTop: Color(0xFF81C784),
    background: Color(0xFFF1F8E9),
    backgroundBottom: Color(0xFF4CAF50),
    primary: Color(0xFF2E7D32),
    primaryDark: Color(0xFF1B5E20),
    secondary: Color(0xFFFFEB3B),
    secondaryDark: Color(0xFFF57F17),
    playfulBlue: Color(0xFF0288D1),
    playfulMint: Color(0xFF00897B),
    panel: Color(0xFFFAFAFA),
    panelBorder: Color(0xFFC8E6C9),
    cardBack: Color(0xFF00796B),
    cardFront: Color(0xFFDCEDC8),
    mismatch: Color(0xFFE53935),
    mismatchBackground: Color(0xFFFFCDD2),
    textDark: Color(0xFF1B381C),
    textMedium: Color(0xFF33691E),
    textLight: Color(0xFF689F38),
    lavender: Color(0xFF8E24AA),
  );

  static const _jungleDark = AppPalette(
    backgroundTop: Color(0xFF0B2211),
    background: Color(0xFF06140A),
    backgroundBottom: Color(0xFF0E2E19),
    primary: Color(0xFF66BB6A),
    primaryDark: Color(0xFF4CAF50),
    secondary: Color(0xFFFFEE58),
    secondaryDark: Color(0xFFFBC02D),
    playfulBlue: Color(0xFF4FC3F7),
    playfulMint: Color(0xFF26A69A),
    panel: Color(0xFF132216),
    panelBorder: Color(0xFF224229),
    cardBack: Color(0xFF00695C),
    cardFront: Color(0xFF24382B),
    mismatch: Color(0xFFEF5350),
    mismatchBackground: Color(0xFF421C1C),
    textDark: Color(0xFFE8F5E9),
    textMedium: Color(0xFFC8E6C9),
    textLight: Color(0xFF81C784),
    lavender: Color(0xFFAB47BC),
  );

  // Sabana (Savanna)
  static const _savannaLight = AppPalette(
    backgroundTop: Color(0xFFFFEE58),
    background: Color(0xFFFFFDE7),
    backgroundBottom: Color(0xFFFF9800),
    primary: Color(0xFFE65100),
    primaryDark: Color(0xFFBF360C),
    secondary: Color(0xFFFFC107),
    secondaryDark: Color(0xFFFFA000),
    playfulBlue: Color(0xFF0288D1),
    playfulMint: Color(0xFF388E3C),
    panel: Color(0xFFFFFDE7),
    panelBorder: Color(0xFFFFE082),
    cardBack: Color(0xFFEF6C00),
    cardFront: Color(0xFFFFECB3),
    mismatch: Color(0xFFD32F2F),
    mismatchBackground: Color(0xFFFFCDD2),
    textDark: Color(0xFF3E2723),
    textMedium: Color(0xFF4E342E),
    textLight: Color(0xFF795548),
    lavender: Color(0xFF7B1FA2),
  );

  static const _savannaDark = AppPalette(
    backgroundTop: Color(0xFF261712),
    background: Color(0xFF180F0B),
    backgroundBottom: Color(0xFF331E12),
    primary: Color(0xFFFFB74D),
    primaryDark: Color(0xFFFFA726),
    secondary: Color(0xFFFFD54F),
    secondaryDark: Color(0xFFFFC107),
    playfulBlue: Color(0xFF4FC3F7),
    playfulMint: Color(0xFF81C784),
    panel: Color(0xFF241A15),
    panelBorder: Color(0xFF442E21),
    cardBack: Color(0xFFD84315),
    cardFront: Color(0xFF3D2A22),
    mismatch: Color(0xFFEF5350),
    mismatchBackground: Color(0xFF52281E),
    textDark: Color(0xFFFBE9E7),
    textMedium: Color(0xFFD7CCC8),
    textLight: Color(0xFFA1887F),
    lavender: Color(0xFFBA68C8),
  );

  // Bosque (Forest)
  static const _forestLight = AppPalette(
    backgroundTop: Color(0xFFAED581),
    background: Color(0xFFF9FBE7),
    backgroundBottom: Color(0xFF81C784),
    primary: Color(0xFF33691E),
    primaryDark: Color(0xFF1B5E20),
    secondary: Color(0xFF7CB342),
    secondaryDark: Color(0xFF558B2F),
    playfulBlue: Color(0xFF0288D1),
    playfulMint: Color(0xFF00897B),
    panel: Color(0xFFFCFDF9),
    panelBorder: Color(0xFFDCEDC8),
    cardBack: Color(0xFF2E7D32),
    cardFront: Color(0xFFE8F5E9),
    mismatch: Color(0xFFD32F2F),
    mismatchBackground: Color(0xFFFFCDD2),
    textDark: Color(0xFF1B331C),
    textMedium: Color(0xFF33691E),
    textLight: Color(0xFF689F38),
    lavender: Color(0xFF7B1FA2),
  );

  static const _forestDark = AppPalette(
    backgroundTop: Color(0xFF14241B),
    background: Color(0xFF0B140F),
    backgroundBottom: Color(0xFF1C3326),
    primary: Color(0xFF81C784),
    primaryDark: Color(0xFF66BB6A),
    secondary: Color(0xFFAED581),
    secondaryDark: Color(0xFF9CCC65),
    playfulBlue: Color(0xFF4FC3F7),
    playfulMint: Color(0xFF26A69A),
    panel: Color(0xFF17241D),
    panelBorder: Color(0xFF2A4234),
    cardBack: Color(0xFF388E3C),
    cardFront: Color(0xFF23362A),
    mismatch: Color(0xFFEF5350),
    mismatchBackground: Color(0xFF472323),
    textDark: Color(0xFFE8F5E9),
    textMedium: Color(0xFFC8E6C9),
    textLight: Color(0xFF81C784),
    lavender: Color(0xFFAB47BC),
  );

  static AppPalette paletteFor(GameStyle style, bool isDark) {
    switch (style) {
      case GameStyle.classic:
        return isDark ? dark : light;
      case GameStyle.desert:
        return isDark ? _desertDark : _desertLight;
      case GameStyle.jungle:
        return isDark ? _jungleDark : _jungleLight;
      case GameStyle.savanna:
        return isDark ? _savannaDark : _savannaLight;
      case GameStyle.forest:
        return isDark ? _forestDark : _forestLight;
      case GameStyle.prairie:
        return isDark ? _savannaDark : _savannaLight;
      case GameStyle.mountains:
        return isDark ? _forestDark : _forestLight;
      case GameStyle.tundra:
        return isDark ? dark : light;
    }
  }

  static AppPalette of(BuildContext context) => light; // fallback
}
