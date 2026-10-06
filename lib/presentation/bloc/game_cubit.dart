import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/game_config.dart';
import '../../domain/entities/game_style.dart';
import '../../domain/entities/game_statistics.dart';
import '../../domain/entities/memory_card.dart';
import '../../domain/repositories/game_profile_repository.dart';
import '../../domain/repositories/game_score_repository.dart';
import '../../domain/usecases/check_match.dart';
import '../../domain/usecases/generate_board.dart';
import 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit({
    required this._generateBoard,
    required this._checkMatch,
    required this._scoreRepository,
    required this._profileRepository,
    this._config = const GameConfig(),
  }) : super(const GameState()) {
    _profileReady = _loadProfile();
  }

  final GenerateBoard _generateBoard;
  final CheckMatch _checkMatch;
  final GameScoreRepository _scoreRepository;
  final GameProfileRepository _profileRepository;
  final GameConfig _config;

  static const revealCardCost = 15;
  static const findPairCost = 40;
  static const extraTimeCost = 25;

  late final Future<void> _profileReady;
  Timer? _timer;
  int _starCooldownSeconds = 10;
  int? _selectedStarCardId;
  bool _diamondActionPending = false;
  bool _startingGame = false;

  /// Se incrementa en cada partida nueva. Las esperas pendientes de una
  /// partida anterior comparan este valor y se descartan si ya no coincide.
  int _session = 0;

  bool _isActive(int session) => !isClosed && session == _session;

  Future<void> loadScores() async {
    final scores = await _scoreRepository.loadScores(state.gameStyle);
    if (isClosed) return;
    emit(state.copyWith(scores: scores, scoresLoaded: true, score: 0));
  }

  Future<void> loadStatistics() async {
    final statistics = await _scoreRepository.loadStatistics();
    if (isClosed) return;
    emit(state.copyWith(statistics: statistics, statisticsLoaded: true));
  }

  Future<void> _loadProfile() async {
    final diamonds = await _profileRepository.loadDiamonds();
    final isPro = await _profileRepository.loadIsPro();
    if (isClosed) return;
    emit(
      state.copyWith(diamonds: diamonds, accountType: isPro ? 'PRO' : 'BÁSICA'),
    );
  }

  Future<void> selectStyle(GameStyle style, bool isDark) async {
    if (state.phase != GamePhase.initial || _startingGame) return;
    emit(state.copyWith(gameStyle: style, scoresLoaded: false));
    final scores = await _scoreRepository.loadScores(style);
    if (isClosed) return;
    emit(state.copyWith(scores: scores, scoresLoaded: true, score: 0));
  }

  void selectDifficulty(GameDifficulty difficulty) {
    if (state.phase != GamePhase.initial ||
        !state.scoresLoaded ||
        _startingGame) {
      return;
    }
    emit(
      state.copyWith(
        difficulty: difficulty,
        score: 0,
        selectionRequired: false,
      ),
    );
  }

  void clearDifficulty() {
    if (state.phase != GamePhase.initial || _startingGame) return;
    emit(state.copyWith(clearDifficulty: true, selectionRequired: false));
  }

  void selectLevel(GameLevel level) {
    if (state.phase != GamePhase.initial || _startingGame) return;
    emit(state.copyWith(level: level, selectionRequired: false));
  }

  void returnToSetup() {
    _timer?.cancel();
    _timer = null;
    _session++;
    _selectedStarCardId = null;
    emit(
      GameState(
        scores: state.scores,
        scoresLoaded: state.scoresLoaded,
        diamonds: state.diamonds,
        username: state.username,
        accountType: state.accountType,
        gameStyle: state.gameStyle,
        statistics: state.statistics,
        statisticsLoaded: state.statisticsLoaded,
      ),
    );
  }

  /// Inicia una partida nueva con un tablero aleatorio.
  Future<void> startGame(bool isDark) {
    if (state.difficulty == null) {
      emit(state.copyWith(selectionRequired: true));
      return Future<void>.value();
    }
    return _beginGame(
      _generateBoard(
        _config.pairsCountFor(state.level),
        state.gameStyle,
        isDark,
      ),
      isDark,
    );
  }

  /// Genera una partida completamente nueva.
  Future<void> newGame(bool isDark) => _beginGame(
    _generateBoard(_config.pairsCountFor(state.level), state.gameStyle, isDark),
    isDark,
  );

  /// Reinicia la partida manteniendo el orden actual de las cartas o generando nuevas si está vacío.
  Future<void> restartGame(bool isDark) {
    final cards = state.cards.isEmpty
        ? _generateBoard(
            _config.pairsCountFor(state.level),
            state.gameStyle,
            isDark,
          )
        : state.cards
              .map((card) => card.copyWith(status: CardStatus.hidden))
              .toList();

    return _beginGame(cards, isDark);
  }

  Future<void> _beginGame(List<MemoryCard> cards, bool isDark) async {
    if (_startingGame) return;
    _startingGame = true;
    try {
      await _runGame(cards, isDark);
    } finally {
      _startingGame = false;
    }
  }

  Future<void> _runGame(List<MemoryCard> cards, bool isDark) async {
    final difficulty = state.difficulty;
    if (difficulty == null) return;
    _timer?.cancel();
    _timer = null;
    _starCooldownSeconds = 10;
    _selectedStarCardId = null;
    final session = ++_session;
    final statistics = await _scoreRepository.recordGameStarted(
      state.statistics,
      state.gameStyle,
      difficulty,
      state.level,
    );
    if (!_isActive(session)) return;
    emit(state.copyWith(statistics: statistics, statisticsLoaded: true));
    final previewDuration = _config.previewDurationFor(difficulty);
    final animalFact = _generateBoard.getRandomAnimalFact(
      state.gameStyle,
      cards,
    );

    final board = cards
        .map((card) => card.copyWith(status: CardStatus.revealed))
        .toList();

    emit(
      GameState(
        phase: GamePhase.preview,
        cards: board,
        score: 0,
        moves: 0,
        remainingSeconds: 0,
        elapsedSeconds: 0,
        difficulty: difficulty,
        level: state.level,
        gameStyle: state.gameStyle,
        scores: state.scores,
        scoresLoaded: state.scoresLoaded,
        diamonds: state.diamonds,
        username: state.username,
        accountType: state.accountType,
        animalFact: animalFact,
        statistics: state.statistics,
        statisticsLoaded: state.statisticsLoaded,
      ),
    );

    await Future<void>.delayed(previewDuration);
    if (!_isActive(session)) return;

    emit(
      state.copyWith(
        phase: GamePhase.playing,
        cards: _setStatus(state.cards, null, CardStatus.hidden),
        remainingSeconds: _config.roundDuration.inSeconds,
      ),
    );
    _startTimer(session);
  }

  void pauseGame() {
    if (state.phase != GamePhase.playing || state.isResolving) return;
    _timer?.cancel();
    _timer = null;
    emit(state.copyWith(phase: GamePhase.paused));
  }

  void resumeGame() {
    if (state.phase != GamePhase.paused) return;
    emit(state.copyWith(phase: GamePhase.playing));
    _startTimer(_session);
  }

  /// Agrega diamantes como una compra de prueba.
  Future<void> purchaseDiamonds(int amount) async {
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'Must be greater than zero');
    }
    await _profileReady;
    if (isClosed) return;
    final diamonds = state.diamonds + amount;
    await _profileRepository.saveDiamonds(diamonds);
    if (isClosed) return;
    emit(state.copyWith(diamonds: diamonds));
  }

  /// Activa la cuenta PRO como una compra de demostración.
  Future<void> upgradeToPro() async {
    if (state.accountType == 'PRO') return;
    await _profileReady;
    if (isClosed || state.accountType == 'PRO') return;
    await _profileRepository.saveIsPro(true);
    if (isClosed) return;
    emit(state.copyWith(accountType: 'PRO'));
  }

  /// Revela una ficha brevemente.
  Future<bool> revealCardHint() async {
    await _profileReady;
    if (isClosed) return false;
    if (!_canUsePowerUp(revealCardCost)) return false;

    final hiddenCards = state.cards
        .where((card) => card.status == CardStatus.hidden)
        .toList();
    if (hiddenCards.isEmpty) return false;

    final card = hiddenCards[math.Random().nextInt(hiddenCards.length)];
    final session = _session;
    _diamondActionPending = true;
    try {
      final diamonds = state.diamonds - revealCardCost;
      await _profileRepository.saveDiamonds(diamonds);
      if (!_isActive(session)) return false;
      emit(
        state.copyWith(
          diamonds: diamonds,
          cards: _setStatus(state.cards, {card.id}, CardStatus.revealed),
          isResolving: true,
        ),
      );
      unawaited(_hideHint(session, card.id));
      return true;
    } finally {
      _diamondActionPending = false;
    }
  }

  /// Encuentra automáticamente un par.
  Future<bool> findPairHint() async {
    await _profileReady;
    if (isClosed) return false;
    if (!_canUsePowerUp(findPairCost) || state.firstSelectedId != null) {
      return false;
    }

    final pairIds = state.cards
        .where((card) => card.status == CardStatus.hidden)
        .map((card) => card.pairId)
        .toSet();
    List<MemoryCard>? pair;
    for (final pairId in pairIds) {
      final candidate = state.cards
          .where((card) => card.pairId == pairId)
          .toList();
      if (candidate.length == 2 &&
          candidate.every((card) => card.status == CardStatus.hidden)) {
        pair = candidate;
        break;
      }
    }
    if (pair == null) return false;

    final session = _session;
    final pairIdsToReveal = pair.map((card) => card.id).toSet();
    final hasStarBonus = _hasStarBonus(pairIdsToReveal);
    _diamondActionPending = true;
    try {
      final diamonds = state.diamonds - findPairCost;
      await _profileRepository.saveDiamonds(diamonds);
      if (!_isActive(session)) return false;
      emit(
        state.copyWith(
          diamonds: diamonds,
          cards: _setStatus(state.cards, pairIdsToReveal, CardStatus.revealed),
          isResolving: true,
        ),
      );
      unawaited(
        _completeFoundPair(
          session,
          pairIdsToReveal,
          hasStarBonus: hasStarBonus,
        ),
      );
      return true;
    } finally {
      _diamondActionPending = false;
    }
  }

  /// Añade tiempo a una ronda activa.
  Future<bool> addExtraTime() async {
    await _profileReady;
    if (isClosed) return false;
    if (!_canUsePowerUp(extraTimeCost)) return false;
    final session = _session;
    _diamondActionPending = true;
    try {
      final diamonds = state.diamonds - extraTimeCost;
      await _profileRepository.saveDiamonds(diamonds);
      if (!_isActive(session)) return false;
      emit(
        state.copyWith(
          diamonds: diamonds,
          remainingSeconds: state.remainingSeconds + _config.extraTimeSeconds,
        ),
      );
      return true;
    } finally {
      _diamondActionPending = false;
    }
  }

  /// El niño tocó una ficha.
  Future<void> onCardTapped(int cardId) async {
    if (state.phase != GamePhase.playing || state.isResolving) return;

    final tapped = _findCard(cardId);
    if (tapped == null || tapped.status != CardStatus.hidden) return;

    final session = _session;
    final firstId = state.firstSelectedId;

    if (firstId == null) {
      _selectedStarCardId =
          tapped.id == state.starCardId && state.starSecondsRemaining > 0
          ? tapped.id
          : null;
      emit(
        state.copyWith(
          cards: _setStatus(state.cards, {cardId}, CardStatus.revealed),
          firstSelectedId: cardId,
        ),
      );
      return;
    }

    final first = _findCard(firstId)!;
    final hasStarBonus =
        _selectedStarCardId == firstId || _hasStarBonus({firstId, cardId});
    _selectedStarCardId = null;

    if (_checkMatch(first, tapped)) {
      await _resolveMatch(session, firstId, cardId, hasStarBonus: hasStarBonus);
    } else {
      await _resolveMismatch(session, firstId, cardId);
    }
  }

  Future<void> _resolveMatch(
    int session,
    int firstId,
    int secondId, {
    required bool hasStarBonus,
  }) async {
    emit(
      state.copyWith(
        cards: _setStatus(state.cards, {secondId}, CardStatus.revealed),
        clearFirstSelected: true,
        isResolving: true,
        moves: state.moves + 1,
      ),
    );

    await Future<void>.delayed(_config.matchDelay);
    if (!_isActive(session) || state.phase != GamePhase.playing) return;

    final cards = _setStatus(state.cards, {
      firstId,
      secondId,
    }, CardStatus.matched);
    final isFinished = cards.every((card) => card.isMatched);
    final points = _config.pointsPerMatch + (hasStarBonus ? 5 : 0);
    final score = state.score + points;
    final difficulty = state.difficulty;
    if (difficulty == null) return;
    final totalScore = (state.scores[difficulty] ?? 0) + points;
    await _scoreRepository.saveScore(state.gameStyle, difficulty, totalScore);
    if (!_isActive(session)) return;
    final statistics = isFinished
        ? await _scoreRepository.recordGameWin(
            state.statistics,
            GameRecord(
              style: state.gameStyle,
              difficulty: difficulty,
              moves: state.moves,
              seconds: state.elapsedSeconds,
              level: state.level,
            ),
          )
        : state.statistics;
    if (!_isActive(session)) return;
    if (hasStarBonus) _starCooldownSeconds = 10;

    emit(
      state.copyWith(
        cards: cards,
        isResolving: false,
        score: score,
        scores: {...state.scores, difficulty: totalScore},
        statistics: statistics,
        phase: isFinished ? GamePhase.finished : GamePhase.playing,
        clearStarCard: hasStarBonus,
        starSecondsRemaining: hasStarBonus ? 0 : null,
      ),
    );
    if (isFinished) _timer?.cancel();
  }

  Future<void> _resolveMismatch(int session, int firstId, int secondId) async {
    emit(
      state.copyWith(
        cards: _setStatus(state.cards, {
          firstId,
          secondId,
        }, CardStatus.mismatched),
        clearFirstSelected: true,
        isResolving: true,
        moves: state.moves + 1,
      ),
    );

    await Future<void>.delayed(_config.mismatchDuration);
    if (!_isActive(session)) return;

    emit(
      state.copyWith(
        cards: _setStatus(state.cards, {firstId, secondId}, CardStatus.hidden),
        isResolving: false,
      ),
    );
  }

  bool _canUsePowerUp(int cost) =>
      state.phase == GamePhase.playing &&
      !state.isResolving &&
      !_diamondActionPending &&
      state.firstSelectedId == null &&
      state.diamonds >= cost;

  Future<void> _hideHint(int session, int cardId) async {
    await Future<void>.delayed(_config.hintDuration);
    if (!_isActive(session) || state.phase != GamePhase.playing) return;
    emit(
      state.copyWith(
        cards: _setStatus(state.cards, {cardId}, CardStatus.hidden),
        isResolving: false,
      ),
    );
  }

  Future<void> _completeFoundPair(
    int session,
    Set<int> pairIds, {
    required bool hasStarBonus,
  }) async {
    await Future<void>.delayed(_config.matchDelay);
    if (!_isActive(session) || state.phase != GamePhase.playing) return;

    final cards = _setStatus(state.cards, pairIds, CardStatus.matched);
    final isFinished = cards.every((card) => card.isMatched);
    final points = _config.pointsPerMatch + (hasStarBonus ? 5 : 0);
    final score = state.score + points;
    final difficulty = state.difficulty;
    if (difficulty == null) return;
    final totalScore = (state.scores[difficulty] ?? 0) + points;
    await _scoreRepository.saveScore(state.gameStyle, difficulty, totalScore);
    if (!_isActive(session)) return;
    final statistics = isFinished
        ? await _scoreRepository.recordGameWin(
            state.statistics,
            GameRecord(
              style: state.gameStyle,
              difficulty: difficulty,
              moves: state.moves,
              seconds: state.elapsedSeconds,
              level: state.level,
            ),
          )
        : state.statistics;
    if (!_isActive(session)) return;
    if (hasStarBonus) _starCooldownSeconds = 10;

    emit(
      state.copyWith(
        cards: cards,
        isResolving: false,
        score: score,
        scores: {...state.scores, difficulty: totalScore},
        statistics: statistics,
        phase: isFinished ? GamePhase.finished : GamePhase.playing,
        clearStarCard: hasStarBonus,
        starSecondsRemaining: hasStarBonus ? 0 : null,
      ),
    );
    if (isFinished) _timer?.cancel();
  }

  void _startTimer(int session) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isActive(session) || state.phase != GamePhase.playing) {
        timer.cancel();
        return;
      }

      final seconds = state.remainingSeconds - 1;
      if (seconds <= 0) {
        timer.cancel();
        _timer = null;
        _session++;
        _starCooldownSeconds = 10;
        emit(
          state.copyWith(
            phase: GamePhase.timeExpired,
            remainingSeconds: 0,
            elapsedSeconds: state.elapsedSeconds + 1,
            isResolving: false,
            clearFirstSelected: true,
            clearStarCard: true,
            starSecondsRemaining: 0,
          ),
        );
        _selectedStarCardId = null;
        return;
      }
      _advanceStarEvent();
      emit(
        state.copyWith(
          remainingSeconds: seconds,
          elapsedSeconds: state.elapsedSeconds + 1,
        ),
      );
    });
  }

  bool _hasStarBonus(Set<int> cardIds) =>
      state.starCardId != null &&
      cardIds.contains(state.starCardId) &&
      state.starSecondsRemaining > 0;

  void _advanceStarEvent() {
    if (state.starCardId != null) {
      final seconds = state.starSecondsRemaining - 1;
      if (seconds <= 0) {
        _starCooldownSeconds = 10;
        emit(state.copyWith(clearStarCard: true, starSecondsRemaining: 0));
      } else {
        emit(state.copyWith(starSecondsRemaining: seconds));
      }
      return;
    }

    _starCooldownSeconds--;
    if (_starCooldownSeconds > 0) return;

    final hiddenCards = state.cards
        .where((card) => card.status == CardStatus.hidden)
        .toList();
    if (hiddenCards.isEmpty) return;

    final starCard = hiddenCards[math.Random().nextInt(hiddenCards.length)];
    emit(state.copyWith(starCardId: starCard.id, starSecondsRemaining: 5));
  }

  MemoryCard? _findCard(int id) {
    for (final card in state.cards) {
      if (card.id == id) return card;
    }
    return null;
  }

  List<MemoryCard> _setStatus(
    List<MemoryCard> cards,
    Set<int>? ids,
    CardStatus status,
  ) {
    return [
      for (final card in cards)
        if (ids == null || ids.contains(card.id))
          card.copyWith(status: status)
        else
          card,
    ];
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
