import '../entities/game_config.dart';
import '../entities/game_style.dart';
import '../entities/game_statistics.dart';

abstract interface class GameScoreRepository {
  Future<Map<GameDifficulty, int>> loadScores(GameStyle style);

  Future<void> saveScore(GameStyle style, GameDifficulty difficulty, int score);

  Future<GameStatistics> loadStatistics();

  Future<GameStatistics> recordGameStarted(
    GameStatistics statistics,
    GameStyle style,
    GameDifficulty difficulty,
    GameLevel level,
  );

  Future<GameStatistics> recordGameWin(
    GameStatistics statistics,
    GameRecord record,
  );
}
