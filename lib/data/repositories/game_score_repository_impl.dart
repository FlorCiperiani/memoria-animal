import '../../domain/entities/game_config.dart';
import '../../domain/entities/game_style.dart';
import '../../domain/entities/game_statistics.dart';
import '../../domain/repositories/game_score_repository.dart';
import '../datasources/game_score_local_datasource.dart';

class GameScoreRepositoryImpl implements GameScoreRepository {
  const GameScoreRepositoryImpl(this._dataSource);

  final GameScoreLocalDataSource _dataSource;

  @override
  Future<Map<GameDifficulty, int>> loadScores(GameStyle style) async {
    final entries = await Future.wait(
      GameDifficulty.values.map(
        (difficulty) async => MapEntry(
          difficulty,
          await _dataSource.loadScore(style, difficulty),
        ),
      ),
    );
    return Map.unmodifiable(Map.fromEntries(entries));
  }

  @override
  Future<void> saveScore(
    GameStyle style,
    GameDifficulty difficulty,
    int score,
  ) => _dataSource.saveScore(style, difficulty, score);

  @override
  Future<GameStatistics> loadStatistics() async =>
      GameStatistics.fromJsonString(await _dataSource.loadStatistics());

  @override
  Future<GameStatistics> recordGameStarted(
    GameStatistics statistics,
    GameStyle style,
    GameDifficulty difficulty,
    GameLevel level,
  ) => _saveStatistics(statistics.recordStarted(style, difficulty, level));

  @override
  Future<GameStatistics> recordGameWin(
    GameStatistics statistics,
    GameRecord record,
  ) => _saveStatistics(statistics.recordWin(record));

  Future<GameStatistics> _saveStatistics(GameStatistics statistics) async {
    await _dataSource.saveStatistics(statistics.toJsonString());
    return statistics;
  }
}
