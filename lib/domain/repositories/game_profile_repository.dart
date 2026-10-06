abstract interface class GameProfileRepository {
  Future<int> loadDiamonds();

  Future<void> saveDiamonds(int diamonds);

  Future<bool> loadIsPro();

  Future<void> saveIsPro(bool isPro);
}
