import 'package:equatable/equatable.dart';

enum GameDifficulty { easy, medium, hard }

enum GameLevel { one, two, three }

extension GameLevelDetails on GameLevel {
  int get pairsCount => 4 + index;

  String get label => switch (this) {
    GameLevel.one => 'Nivel 1',
    GameLevel.two => 'Nivel 2',
    GameLevel.three => 'Nivel 3',
  };

  String get description => switch (this) {
    GameLevel.one => 'Para empezar y conocer a los animales',
    GameLevel.two => 'Un poquito más de memoria',
    GameLevel.three => '¡Un gran desafío!',
  };

  String get emoji => switch (this) {
    GameLevel.one => '🌱',
    GameLevel.two => '🌿',
    GameLevel.three => '🌳',
  };
}

extension GameDifficultyLabel on GameDifficulty {
  String get label => switch (this) {
    GameDifficulty.easy => 'Fácil',
    GameDifficulty.medium => 'Medio',
    GameDifficulty.hard => 'Difícil',
  };
}

/// Reglas configurables del juego.
class GameConfig extends Equatable {
  const GameConfig({
    this.pairsCount = 4,
    this.previewDuration = const Duration(seconds: 3),
    this.mismatchDuration = const Duration(milliseconds: 1200),
    this.matchDelay = const Duration(milliseconds: 600),
    this.hintDuration = const Duration(seconds: 2),
    this.roundDuration = const Duration(minutes: 1),
    this.extraTimeSeconds = 30,
    this.pointsPerMatch = 10,
  });

  /// Cantidad de pares del primer nivel (4 pares = 8 fichas).
  final int pairsCount;

  int pairsCountFor(GameLevel level) => pairsCount + level.index;

  /// Tiempo que se muestran todas las fichas al comenzar.
  final Duration previewDuration;

  Duration previewDurationFor(GameDifficulty difficulty) =>
      switch (difficulty) {
        GameDifficulty.easy => previewDuration + const Duration(seconds: 1),
        GameDifficulty.medium => previewDuration,
        GameDifficulty.hard => Duration(
          microseconds: previewDuration.inMicroseconds * 2 ~/ 3,
        ),
      };

  /// Tiempo que se muestran en rojo dos fichas que no son par.
  final Duration mismatchDuration;

  /// Tiempo que se ve un par correcto antes de desaparecer.
  final Duration matchDelay;

  /// Tiempo que permanece visible una carta revelada como ayuda.
  final Duration hintDuration;

  /// Duración inicial de cada ronda.
  final Duration roundDuration;

  /// Segundos añadidos por la ayuda de tiempo.
  final int extraTimeSeconds;

  /// Puntos que suma cada par encontrado.
  final int pointsPerMatch;

  @override
  List<Object?> get props => [
    pairsCount,
    previewDuration,
    mismatchDuration,
    matchDelay,
    hintDuration,
    roundDuration,
    extraTimeSeconds,
    pointsPerMatch,
  ];
}
