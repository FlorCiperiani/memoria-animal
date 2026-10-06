abstract interface class AudioRepository {
  Future<void> playThemeAmbient({required bool isDark});

  Future<void> pauseThemeAmbient();

  Future<void> resumeThemeAmbient();

  Future<void> setAmbientEnabled(bool enabled);

  Future<void> setEffectsEnabled(bool enabled);

  Future<void> playCorrectPair();

  Future<void> playIncorrectPair();

  Future<void> playVictory();

  Future<void> stopVictory();

  Future<void> dispose();
}
