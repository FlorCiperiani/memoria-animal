import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/game_profile_repository.dart';

class GameProfileRepositoryImpl implements GameProfileRepository {
  GameProfileRepositoryImpl({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _diamondsKey = 'game.profile.diamonds';
  static const _isProKey = 'game.profile.isPro';
  static const _ambientEnabledKey = 'game.settings.ambientEnabled';
  static const _effectsEnabledKey = 'game.settings.effectsEnabled';
  static const _tutorialSeenKey = 'game.settings.tutorialSeen';

  final SharedPreferencesAsync _preferences;

  @override
  Future<int> loadDiamonds() async =>
      await _preferences.getInt(_diamondsKey) ?? 100;

  @override
  Future<void> saveDiamonds(int diamonds) =>
      _preferences.setInt(_diamondsKey, diamonds);

  @override
  Future<bool> loadIsPro() async =>
      await _preferences.getBool(_isProKey) ?? false;

  @override
  Future<void> saveIsPro(bool isPro) => _preferences.setBool(_isProKey, isPro);

  @override
  Future<bool> loadAmbientEnabled() async =>
      await _preferences.getBool(_ambientEnabledKey) ?? true;

  @override
  Future<void> saveAmbientEnabled(bool enabled) =>
      _preferences.setBool(_ambientEnabledKey, enabled);

  @override
  Future<bool> loadEffectsEnabled() async =>
      await _preferences.getBool(_effectsEnabledKey) ?? true;

  @override
  Future<void> saveEffectsEnabled(bool enabled) =>
      _preferences.setBool(_effectsEnabledKey, enabled);

  @override
  Future<bool> loadTutorialSeen() async =>
      await _preferences.getBool(_tutorialSeenKey) ?? false;

  @override
  Future<void> saveTutorialSeen(bool seen) =>
      _preferences.setBool(_tutorialSeenKey, seen);
}
