import 'dart:math';

import '../entities/game_style.dart';
import '../entities/memory_card.dart';
import '../repositories/card_repository.dart';

/// Crea un tablero mezclado con `pairsCount` pares de fichas boca abajo.
class GenerateBoard {
  GenerateBoard(this._repository, {Random? random})
    : _random = random ?? Random();

  final CardRepository _repository;
  final Random _random;

  String? getRandomAnimalFact(GameStyle style, List<MemoryCard> cards) =>
      _repository.getRandomAnimalFact(
        style,
        cards.map((card) => card.symbol).toSet().toList(),
      );

  List<MemoryCard> call(int pairsCount, GameStyle style, bool isDark) {
    final symbols = [..._repository.getSymbols(style, isDark, pairsCount)]
      ..shuffle(_random);

    if (pairsCount <= 0 || pairsCount > symbols.length) {
      throw ArgumentError.value(
        pairsCount,
        'pairsCount',
        'Debe estar entre 1 y ${symbols.length}',
      );
    }

    final cards = <MemoryCard>[];
    for (var pairId = 0; pairId < pairsCount; pairId++) {
      final symbol = symbols[pairId];
      final animalName = _repository.getAnimalName(style, isDark, symbol);
      cards
        ..add(
          MemoryCard(
            id: pairId * 2,
            pairId: pairId,
            symbol: symbol,
            customAnimalName: animalName,
          ),
        )
        ..add(
          MemoryCard(
            id: pairId * 2 + 1,
            pairId: pairId,
            symbol: symbol,
            customAnimalName: animalName,
          ),
        );
    }

    return cards..shuffle(_random);
  }
}
