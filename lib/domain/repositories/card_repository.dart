import '../entities/game_style.dart';

/// Contrato para obtener los símbolos disponibles para las fichas según el estilo y modo.
abstract interface class CardRepository {
  List<String> getSymbols(GameStyle style, bool isDark, int pairsCount);

  String? getAnimalName(GameStyle style, bool isDark, String symbol);

  String? getRandomAnimalFact(GameStyle style, List<String> symbols);
}
