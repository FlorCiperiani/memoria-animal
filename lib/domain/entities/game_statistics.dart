import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'game_config.dart';
import 'game_style.dart';

class GameRecord extends Equatable {
  const GameRecord({
    required this.style,
    required this.difficulty,
    required this.moves,
    required this.seconds,
    this.level = GameLevel.one,
  });

  final GameStyle style;
  final GameDifficulty difficulty;
  final int moves;
  final int seconds;
  final GameLevel level;

  factory GameRecord.fromJson(Map<String, dynamic> json) => GameRecord(
    style: GameStyle.values.byName(json['style'] as String),
    difficulty: GameDifficulty.values.byName(json['difficulty'] as String),
    moves: json['moves'] as int,
    seconds: json['seconds'] as int,
    level: GameLevel.values.byName(json['level'] as String? ?? 'one'),
  );

  Map<String, dynamic> toJson() => {
    'style': style.name,
    'difficulty': difficulty.name,
    'moves': moves,
    'seconds': seconds,
    'level': level.name,
  };

  @override
  List<Object?> get props => [style, difficulty, moves, seconds, level];
}

class GameStatistics extends Equatable {
  const GameStatistics({
    this.totalPlayed = 0,
    this.playsByStyle = const {},
    this.playsByDifficulty = const {},
    this.playsByLevel = const {},
    this.fewestMovesWins = const [],
    this.fastestWins = const [],
  });

  static const empty = GameStatistics();
  static const leaderboardSize = 10;

  final int totalPlayed;
  final Map<GameStyle, int> playsByStyle;
  final Map<GameDifficulty, int> playsByDifficulty;
  final Map<GameLevel, int> playsByLevel;
  final List<GameRecord> fewestMovesWins;
  final List<GameRecord> fastestWins;

  factory GameStatistics.fromJsonString(String? source) {
    if (source == null) return empty;
    final json = jsonDecode(source) as Map<String, dynamic>;
    final styleCounts = json['playsByStyle'] as Map<String, dynamic>? ?? {};
    final difficultyCounts =
        json['playsByDifficulty'] as Map<String, dynamic>? ?? {};
    final levelCounts = json['playsByLevel'] as Map<String, dynamic>? ?? {};

    return GameStatistics(
      totalPlayed: json['totalPlayed'] as int? ?? 0,
      playsByStyle: {
        for (final style in GameStyle.values)
          style: styleCounts[style.name] as int? ?? 0,
      },
      playsByDifficulty: {
        for (final difficulty in GameDifficulty.values)
          difficulty: difficultyCounts[difficulty.name] as int? ?? 0,
      },
      playsByLevel: {
        for (final level in GameLevel.values)
          level: levelCounts[level.name] as int? ?? 0,
      },
      fewestMovesWins: [
        for (final record in json['fewestMovesWins'] as List<dynamic>? ?? [])
          GameRecord.fromJson(record as Map<String, dynamic>),
      ],
      fastestWins: [
        for (final record in json['fastestWins'] as List<dynamic>? ?? [])
          GameRecord.fromJson(record as Map<String, dynamic>),
      ],
    );
  }

  String toJsonString() => jsonEncode({
    'totalPlayed': totalPlayed,
    'playsByStyle': {
      for (final style in GameStyle.values)
        style.name: playsByStyle[style] ?? 0,
    },
    'playsByDifficulty': {
      for (final difficulty in GameDifficulty.values)
        difficulty.name: playsByDifficulty[difficulty] ?? 0,
    },
    'playsByLevel': {
      for (final level in GameLevel.values)
        level.name: playsByLevel[level] ?? 0,
    },
    'fewestMovesWins': fewestMovesWins.map((record) => record.toJson()).toList(),
    'fastestWins': fastestWins.map((record) => record.toJson()).toList(),
  });

  GameStatistics recordStarted(
    GameStyle style,
    GameDifficulty difficulty,
    GameLevel level,
  ) =>
      GameStatistics(
        totalPlayed: totalPlayed + 1,
        playsByStyle: {...playsByStyle, style: (playsByStyle[style] ?? 0) + 1},
        playsByDifficulty: {
          ...playsByDifficulty,
          difficulty: (playsByDifficulty[difficulty] ?? 0) + 1,
        },
        playsByLevel: {...playsByLevel, level: (playsByLevel[level] ?? 0) + 1},
        fewestMovesWins: fewestMovesWins,
        fastestWins: fastestWins,
      );

  GameStatistics recordWin(GameRecord record) {
    final movesRanking = [...fewestMovesWins, record]
      ..sort((a, b) {
        final movesComparison = a.moves.compareTo(b.moves);
        return movesComparison != 0
            ? movesComparison
            : a.seconds.compareTo(b.seconds);
      });
    final timeRanking = [...fastestWins, record]
      ..sort((a, b) {
        final timeComparison = a.seconds.compareTo(b.seconds);
        return timeComparison != 0
            ? timeComparison
            : a.moves.compareTo(b.moves);
      });

    return GameStatistics(
      totalPlayed: totalPlayed,
      playsByStyle: playsByStyle,
      playsByDifficulty: playsByDifficulty,
      playsByLevel: playsByLevel,
      fewestMovesWins: movesRanking.take(leaderboardSize).toList(),
      fastestWins: timeRanking.take(leaderboardSize).toList(),
    );
  }

  @override
  List<Object?> get props => [
    totalPlayed,
    playsByStyle,
    playsByDifficulty,
    playsByLevel,
    fewestMovesWins,
    fastestWins,
  ];
}
