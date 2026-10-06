import '../../domain/entities/game_style.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/card_local_datasource.dart';

class CardRepositoryImpl implements CardRepository {
  const CardRepositoryImpl(this._dataSource);

  final CardLocalDataSource _dataSource;

  @override
  List<String> getSymbols(GameStyle style, bool isDark, int pairsCount) =>
      List.unmodifiable(_dataSource.getSymbols(style, isDark, pairsCount));

  @override
  String? getAnimalName(GameStyle style, bool isDark, String symbol) =>
      _dataSource.getAnimalName(style, isDark, symbol);

  @override
  String? getRandomAnimalFact(GameStyle style, List<String> symbols) =>
      _dataSource.getRandomAnimalFact(style, symbols);
}
