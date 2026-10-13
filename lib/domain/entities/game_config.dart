import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum GameDifficulty { easy, medium, hard }

enum GameMode { tiempoExtra, tiempoJusto, contraReloj }

extension GameModeDetails on GameMode {
  String get label => switch (this) {
    GameMode.tiempoExtra => 'Tiempo extra',
    GameMode.tiempoJusto => 'Tiempo justo',
    GameMode.contraReloj => 'Contra reloj',
  };

  IconData get icon => switch (this) {
    GameMode.tiempoExtra => Icons.hourglass_empty_rounded,
    GameMode.tiempoJusto => Icons.timer_rounded,
    GameMode.contraReloj => Icons.bolt_rounded,
  };

  GameDifficulty get difficulty => switch (this) {
    GameMode.tiempoExtra => GameDifficulty.easy,
    GameMode.tiempoJusto => GameDifficulty.medium,
    GameMode.contraReloj => GameDifficulty.hard,
  };
}

enum GameLevel { one, two, three }

extension GameLevelDetails on GameLevel {
  int get pairsCount => switch (this) {
    GameLevel.one => 3,
    GameLevel.two => 6,
    GameLevel.three => 9,
  };

  String get label => switch (this) {
    GameLevel.one => 'Fácil',
    GameLevel.two => 'Medio',
    GameLevel.three => 'Difícil',
  };

  String get description => switch (this) {
    GameLevel.one => 'Nivel fácil (6 cartas)',
    GameLevel.two => 'Nivel medio (12 cartas)',
    GameLevel.three => 'Nivel difícil (18 cartas)',
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

  int pairsCountFor(GameLevel level) => level.pairsCount;

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
