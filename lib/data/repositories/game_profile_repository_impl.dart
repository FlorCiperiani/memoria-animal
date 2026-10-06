import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/game_profile_repository.dart';

class GameProfileRepositoryImpl implements GameProfileRepository {
  GameProfileRepositoryImpl({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _diamondsKey = 'game.profile.diamonds';
  static const _isProKey = 'game.profile.isPro';

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
}
