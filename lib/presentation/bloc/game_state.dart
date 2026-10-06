import 'package:equatable/equatable.dart';

import '../../domain/entities/game_config.dart';
import '../../domain/entities/game_style.dart';
import '../../domain/entities/game_statistics.dart';
import '../../domain/entities/memory_card.dart';

enum GamePhase {
  /// Todavía no se generó el tablero.
  initial,

  /// Todas las fichas se muestran para que el niño las memorice.
  preview,

  /// El niño puede tocar las fichas.
  playing,

  /// La partida conserva el tablero y el tiempo hasta que se reanude.
  paused,

  /// Se encontraron todos los pares.
  finished,

  /// El tiempo de la ronda se agotó.
  timeExpired,
}

class GameState extends Equatable {
  const GameState({
    this.phase = GamePhase.initial,
    this.cards = const [],
    this.firstSelectedId,
    this.isResolving = false,
    this.score = 0,
    this.moves = 0,
    this.remainingSeconds = 0,
    this.elapsedSeconds = 0,
    this.starCardId,
    this.starSecondsRemaining = 0,
    this.difficulty,
    this.level = GameLevel.one,
    this.gameStyle = GameStyle.classic,
    this.scores = const {},
    this.scoresLoaded = false,
    this.selectionRequired = false,
    this.diamonds = 100,
    this.username = 'Luna',
    this.accountType = 'BÁSICA',
    this.animalFact,
    this.statistics = GameStatistics.empty,
    this.statisticsLoaded = false,
  });

  final GamePhase phase;
  final List<MemoryCard> cards;

  /// Id de la primera ficha del intento actual (null si no hay ninguna).
  final int? firstSelectedId;

  /// `true` mientras se resuelve un intento; bloquea nuevos toques.
  final bool isResolving;

  final int score;
  final int moves;
  final int remainingSeconds;
  final int elapsedSeconds;
  final int? starCardId;
  final int starSecondsRemaining;
  final GameDifficulty? difficulty;
  final GameLevel level;
  final GameStyle gameStyle;
  final Map<GameDifficulty, int> scores;
  final bool scoresLoaded;
  final bool selectionRequired;
  final int diamonds;
  final String username;
  final String accountType;
  final String? animalFact;
  final GameStatistics statistics;
  final bool statisticsLoaded;

  int get totalPairs => cards.length ~/ 2;
  int get matchedPairs => cards.where((card) => card.isMatched).length ~/ 2;

  GameState copyWith({
    GamePhase? phase,
    List<MemoryCard>? cards,
    int? firstSelectedId,
    bool clearFirstSelected = false,
    bool? isResolving,
    int? score,
    int? moves,
    int? remainingSeconds,
    int? elapsedSeconds,
    int? starCardId,
    bool clearStarCard = false,
    int? starSecondsRemaining,
    GameDifficulty? difficulty,
    bool clearDifficulty = false,
    GameLevel? level,
    GameStyle? gameStyle,
    Map<GameDifficulty, int>? scores,
    bool? scoresLoaded,
    bool? selectionRequired,
    int? diamonds,
    String? username,
    String? accountType,
    String? animalFact,
    bool clearAnimalFact = false,
    GameStatistics? statistics,
    bool? statisticsLoaded,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      cards: cards ?? this.cards,
      firstSelectedId: clearFirstSelected
          ? null
          : (firstSelectedId ?? this.firstSelectedId),
      isResolving: isResolving ?? this.isResolving,
      score: score ?? this.score,
      moves: moves ?? this.moves,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      starCardId: clearStarCard ? null : (starCardId ?? this.starCardId),
      starSecondsRemaining: starSecondsRemaining ?? this.starSecondsRemaining,
      difficulty: clearDifficulty ? null : difficulty ?? this.difficulty,
      level: level ?? this.level,
      gameStyle: gameStyle ?? this.gameStyle,
      scores: scores ?? this.scores,
      scoresLoaded: scoresLoaded ?? this.scoresLoaded,
      selectionRequired: selectionRequired ?? this.selectionRequired,
      diamonds: diamonds ?? this.diamonds,
      username: username ?? this.username,
      accountType: accountType ?? this.accountType,
      animalFact: clearAnimalFact ? null : animalFact ?? this.animalFact,
      statistics: statistics ?? this.statistics,
      statisticsLoaded: statisticsLoaded ?? this.statisticsLoaded,
    );
  }

  @override
  List<Object?> get props => [
    phase,
    cards,
    firstSelectedId,
    isResolving,
    score,
    moves,
    remainingSeconds,
    elapsedSeconds,
    starCardId,
    starSecondsRemaining,
    difficulty,
    level,
    gameStyle,
    scores,
    scoresLoaded,
    selectionRequired,
    diamonds,
    username,
    accountType,
    animalFact,
    statistics,
    statisticsLoaded,
  ];
}
