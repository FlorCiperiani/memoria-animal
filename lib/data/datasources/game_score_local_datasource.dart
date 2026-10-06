import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/game_config.dart';
import '../../domain/entities/game_style.dart';

class GameScoreLocalDataSource {
  GameScoreLocalDataSource({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _keyPrefix = 'game.score.';
  static const _statisticsKey = 'game.statistics';

  final SharedPreferencesAsync _preferences;

  Future<int> loadScore(GameStyle style, GameDifficulty difficulty) async =>
      await _preferences.getInt('$_keyPrefix${style.name}.${difficulty.name}') ??
      0;

  Future<void> saveScore(
    GameStyle style,
    GameDifficulty difficulty,
    int score,
  ) => _preferences.setInt(
    '$_keyPrefix${style.name}.${difficulty.name}',
    score,
  );

  Future<String?> loadStatistics() => _preferences.getString(_statisticsKey);

  Future<void> saveStatistics(String statistics) =>
      _preferences.setString(_statisticsKey, statistics);
}
