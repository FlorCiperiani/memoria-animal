abstract interface class GameProfileRepository {
  Future<int> loadDiamonds();

  Future<void> saveDiamonds(int diamonds);

  Future<bool> loadIsPro();

  Future<void> saveIsPro(bool isPro);

  Future<bool> loadAmbientEnabled();

  Future<void> saveAmbientEnabled(bool enabled);

  Future<bool> loadEffectsEnabled();

  Future<void> saveEffectsEnabled(bool enabled);

  Future<bool> loadTutorialSeen();

  Future<void> saveTutorialSeen(bool seen);
}
