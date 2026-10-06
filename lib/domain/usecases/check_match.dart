import '../entities/memory_card.dart';

/// Regla de negocio: dos fichas distintas forman un par si comparten `pairId`.
class CheckMatch {
  const CheckMatch();

  bool call(MemoryCard a, MemoryCard b) {
    return a.id != b.id && a.pairId == b.pairId;
  }
}
