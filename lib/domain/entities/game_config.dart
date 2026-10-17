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

/// Sistema centralizado de economía de diamantes del juego.
class GameEconomy {
  const GameEconomy._();

  // Costos actualizados y equilibrados de las ayudas
  static const int revealCardCost = 10;
  static const int findPairCost = 30;
  static const int extraTimeCost = 20;

  // Recompensas base por dificultad
  static int baseRewardFor(GameLevel level) => switch (level) {
    GameLevel.one => 10,   // Fácil (3 pares)
    GameLevel.two => 20,   // Medio (6 pares)
    GameLevel.three => 30, // Difícil (9 pares)
  };

  // Multiplicadores por modo de juego
  static double multiplierFor(GameMode mode) => switch (mode) {
    GameMode.tiempoExtra => 0.75,
    GameMode.tiempoJusto => 1.00,
    GameMode.contraReloj => 1.30,
  };

  // Límites máximos de diamantes por partida (9 combinaciones Mode x Level)
  static int maxRewardFor(GameMode mode, GameLevel level) {
    switch (mode) {
      case GameMode.tiempoExtra:
        return switch (level) {
          GameLevel.one => 6,
          GameLevel.two => 12,
          GameLevel.three => 18,
        };
      case GameMode.tiempoJusto:
        return switch (level) {
          GameLevel.one => 8,
          GameLevel.two => 16,
          GameLevel.three => 24,
        };
      case GameMode.contraReloj:
        return switch (level) {
          GameLevel.one => 10,
          GameLevel.two => 20,
          GameLevel.three => 30,
        };
    }
  }

  /// Fórmula determinista de cálculo de diamantes ganados al completar una partida.
  static int calculateReward({
    required GameLevel level,
    required GameMode mode,
    required int moves,
    required int remainingSeconds,
    required bool isFinished,
  }) {
    if (!isFinished) return 0;

    final minAttempts = level.pairsCount;
    final actualMoves = moves < minAttempts ? minAttempts : moves;
    
    // Factor de precisión: menor cantidad de intentos adicionales da mayor bonificación
    final precisionFactor = minAttempts / actualMoves;

    // Factor de tiempo: terminar con más segundos restantes
    final timeFactor = 0.5 + 0.5 * (remainingSeconds / 60.0).clamp(0.0, 1.0);

    final base = baseRewardFor(level);
    final multiplier = multiplierFor(mode);

    // Cálculo único con redondeo final a entero positivo
    final rawReward = (base * multiplier * precisionFactor * timeFactor).round();
    final maxCap = maxRewardFor(mode, level);

    return rawReward.clamp(1, maxCap);
  }
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

  Duration roundDurationFor(GameLevel level, GameMode mode) {
    switch (level) {
      case GameLevel.one: // Fácil
        return switch (mode) {
          GameMode.tiempoExtra => const Duration(seconds: 60),
          GameMode.tiempoJusto => const Duration(seconds: 45),
          GameMode.contraReloj => const Duration(seconds: 30),
        };
      case GameLevel.two: // Medio
        return switch (mode) {
          GameMode.tiempoExtra => const Duration(seconds: 100),
          GameMode.tiempoJusto => const Duration(seconds: 75),
          GameMode.contraReloj => const Duration(seconds: 50),
        };
      case GameLevel.three: // Difícil
        return switch (mode) {
          GameMode.tiempoExtra => const Duration(seconds: 160),
          GameMode.tiempoJusto => const Duration(seconds: 120),
          GameMode.contraReloj => const Duration(seconds: 80),
        };
    }
  }

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
