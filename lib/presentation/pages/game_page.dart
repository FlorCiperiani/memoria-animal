import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/injection.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_surfaces.dart';
import '../../domain/entities/game_config.dart';
import '../../domain/entities/game_style.dart';
import '../../domain/entities/game_statistics.dart';
import '../bloc/game_cubit.dart';
import '../bloc/game_state.dart';
import '../widgets/advertisement_dialog.dart';
import '../widgets/game_board.dart';
import '../widgets/score_board.dart';

enum _DiamondOption { purchase, advertisement }

bool _requiresPro(GameStyle style) => const {
  GameStyle.prairie,
  GameStyle.mountains,
  GameStyle.tundra,
}.contains(style);

class GamePage extends StatelessWidget {
  const GamePage({required this.onThemeModeChanged, super.key});

  final ValueChanged<bool> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameCubit>(
      create: (_) {
        final cubit = sl<GameCubit>();
        unawaited(cubit.loadScores());
        unawaited(cubit.loadStatistics());
        return cubit;
      },
      child: _GameView(onThemeModeChanged: onThemeModeChanged),
    );
  }
}

class _GameView extends StatelessWidget {
  const _GameView({required this.onThemeModeChanged});

  final ValueChanged<bool> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<GameCubit, GameState>(
      listenWhen: (previous, current) =>
          previous.phase != current.phase &&
          (current.phase == GamePhase.paused ||
              current.phase == GamePhase.finished ||
              current.phase == GamePhase.timeExpired),
      listener: (context, state) {
        if (state.phase == GamePhase.paused) {
          _showPauseDialog(context);
        } else {
          _showEndDialog(context, state);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            BlocBuilder<GameCubit, GameState>(
              buildWhen: (previous, current) =>
                  previous.gameStyle != current.gameStyle,
              builder: (context, state) => AppBackdrop(
                gameStyle: state.gameStyle,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      children: [
                        BlocBuilder<GameCubit, GameState>(
                          buildWhen: (previous, current) =>
                              previous.phase != current.phase,
                          builder: (context, state) => _Header(
                            onThemeModeChanged: onThemeModeChanged,
                            canChangeTheme: state.phase == GamePhase.initial,
                            onOpenSettings: () => _openSettings(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        BlocBuilder<GameCubit, GameState>(
                          buildWhen: (previous, current) =>
                              previous.username != current.username ||
                              previous.accountType != current.accountType ||
                              previous.score != current.score ||
                              previous.diamonds != current.diamonds,
                          builder: (context, state) => _PlayerHeader(
                            state: state,
                            onOpenShop: () => _openDiamondShop(context),
                            onUpgradeAccount: () => _openProUpgrade(context),
                            onDowngradeAccount: () =>
                                _confirmProDowngrade(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        BlocBuilder<GameCubit, GameState>(
                          buildWhen: (previous, current) =>
                              previous.phase != current.phase ||
                              previous.scores != current.scores ||
                              previous.scoresLoaded != current.scoresLoaded ||
                              previous.selectionRequired !=
                                  current.selectionRequired ||
                              previous.difficulty != current.difficulty ||
                              previous.level != current.level ||
                              previous.gameStyle != current.gameStyle ||
                              previous.accountType != current.accountType ||
                              previous.statistics != current.statistics ||
                              previous.statisticsLoaded !=
                                  current.statisticsLoaded ||
                              previous.moves != current.moves ||
                              previous.matchedPairs != current.matchedPairs ||
                              previous.totalPairs != current.totalPairs ||
                              previous.remainingSeconds !=
                                  current.remainingSeconds ||
                              previous.isResolving != current.isResolving ||
                              previous.cards != current.cards ||
                              previous.diamonds != current.diamonds,
                          builder: (context, state) {
                            if (state.phase == GamePhase.initial) {
                              return Expanded(
                                child: _GameSetup(
                                  state: state,
                                  onSelectDifficulty: context
                                      .read<GameCubit>()
                                      .selectDifficulty,
                                  onClearDifficulty: context
                                      .read<GameCubit>()
                                      .clearDifficulty,
                                  onSelectLevel: context
                                      .read<GameCubit>()
                                      .selectLevel,
                                  onSelectStyle: (style) {
                                    final cubit = context.read<GameCubit>();
                                    if (_requiresPro(style) &&
                                        state.accountType != 'PRO') {
                                      _showProRequiredDialog(context);
                                      return;
                                    }
                                    cubit.selectStyle(
                                      style,
                                      Theme.of(context).brightness ==
                                          Brightness.dark,
                                    );
                                  },
                                  onStart: () =>
                                      context.read<GameCubit>().startGame(
                                        Theme.of(context).brightness ==
                                            Brightness.dark,
                                      ),
                                  onOpenRanking: () => _showRanking(
                                    context,
                                    state.gameStyle,
                                    state.statistics,
                                    state.statisticsLoaded,
                                  ),
                                  isDark: isDark,
                                ),
                              );
                            }

                            return Expanded(
                              child: Column(
                                children: [
                                  ScoreBoard(
                                    moves: state.moves,
                                    matchedPairs: state.matchedPairs,
                                    totalPairs: state.totalPairs,
                                    remainingSeconds: state.remainingSeconds,
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 12,
                                    runSpacing: 4,
                                    children: [
                                      Text(
                                        'Temática: ${state.gameStyle.label} ${state.gameStyle.emoji}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        'Dificultad: ${state.difficulty!.label}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        '${state.level.label} ${state.level.emoji}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _GameControlBar(
                                    state: state,
                                    onPause: () =>
                                        context.read<GameCubit>().pauseGame(),
                                    onRestart: () =>
                                        context.read<GameCubit>().restartGame(
                                          Theme.of(context).brightness ==
                                              Brightness.dark,
                                        ),
                                    onNewGame: () => _startNewGame(context),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: Center(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 680,
                                        ),
                                        child: GameBoard(
                                          cards: state.cards,
                                          starCardId: state.starCardId,
                                          onCardTap: context
                                              .read<GameCubit>()
                                              .onCardTapped,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _PowerUpBar(
                                    enabled:
                                        state.phase == GamePhase.playing &&
                                        !state.isResolving &&
                                        state.firstSelectedId == null,
                                    onRevealCard: () => _usePowerUp(
                                      context,
                                      GameCubit.revealCardCost,
                                      (cubit) => cubit.revealCardHint(),
                                    ),
                                    onFindPair: () => _usePowerUp(
                                      context,
                                      GameCubit.findPairCost,
                                      (cubit) => cubit.findPairHint(),
                                    ),
                                    onAddTime: () => _usePowerUp(
                                      context,
                                      GameCubit.extraTimeCost,
                                      (cubit) => cubit.addExtraTime(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Positioned.fill(child: _PairEncouragementOverlay()),
          ],
        ),
      ),
    );
  }

  Future<void> _showPauseDialog(BuildContext context) {
    final cubit = context.read<GameCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors.paletteFor(cubit.state.gameStyle, isDark);
    final buttonColor = isDark
        ? Color.lerp(colors.primaryDark, Colors.black, 0.35)!
        : colors.primaryDark;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Partida pausada', textAlign: TextAlign.center),
          content: const Text(
            'El juego está en pausa. Cuando quieras, podés continuar.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton.icon(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _showAdvertisement(context, cubit);
                if (!context.mounted) return;
                cubit.resumeGame();
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Continuar'),
              style: FilledButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEndDialog(BuildContext context, GameState state) {
    final cubit = context.read<GameCubit>();
    final hasWon = state.phase == GamePhase.finished;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          hasWon ? '¡Ganaste! 🎉' : 'Se acabó el tiempo',
          textAlign: TextAlign.center,
        ),
        content: Text(
          [
            'Puntaje: ${state.score}\nIntentos: ${state.moves}',
            if (hasWon && state.animalFact != null)
              '\n¿Sabías que...? ${state.animalFact}',
          ].join('\n'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () async {
              if (hasWon) await cubit.stopVictorySound();
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
              if (hasWon) {
                await _showAdvertisement(context, cubit);
                if (!context.mounted) return;
              }
              cubit.returnToSetup();
            },
            child: const Text('Salir'),
          ),
          FilledButton(
            onPressed: () async {
              if (hasWon) await cubit.stopVictorySound();
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
              if (hasWon) {
                await _showAdvertisement(context, cubit);
                if (!context.mounted) return;
              }
              if (!context.mounted) return;
              cubit.startGame(Theme.of(context).brightness == Brightness.dark);
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text('Otra partida'),
          ),
        ],
      ),
    );
  }

  Future<void> _startNewGame(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<GameCubit>();
    await _showAdvertisement(context, cubit);
    if (!context.mounted) return;
    await cubit.newGame(isDark);
  }

  Future<void> _showAdvertisement(BuildContext context, GameCubit cubit) async {
    if (cubit.state.accountType != 'PRO') {
      await showRandomAdvertisement(context);
    }
  }

  Future<void> _showProRequiredDialog(BuildContext context) {
    final state = context.read<GameCubit>().state;
    final palette = AppColors.paletteFor(
      state.gameStyle,
      Theme.of(context).brightness == Brightness.dark,
    );
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Temática exclusiva PRO'),
        content: const Text(
          'Pasate a PRO para desbloquear Pradera, Montañas y Tundra, además de jugar sin publicidad.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Salir'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _openProUpgrade(context);
            },
            icon: const Icon(Icons.star_rounded),
            label: const Text('Pasar a PRO'),
            style: FilledButton.styleFrom(
              backgroundColor: Color.lerp(
                palette.secondary,
                Colors.black,
                0.08,
              ),
              foregroundColor: const Color(0xFF332500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSettings(BuildContext context) async {
    final cubit = context.read<GameCubit>();
    await cubit.ensureProfileLoaded();
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: BlocBuilder<GameCubit, GameState>(
              builder: (context, state) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Configuración',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.music_note_rounded),
                    title: const Text('Sonido'),
                    subtitle: const Text(
                      'Ambiente día/noche y sonido de victoria',
                    ),
                    value: state.ambientEnabled,
                    onChanged: cubit.setAmbientEnabled,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.volume_up_rounded),
                    title: const Text('Efectos'),
                    subtitle: const Text(
                      'Sonidos de pares correctos e incorrectos',
                    ),
                    value: state.effectsEnabled,
                    onChanged: cubit.setEffectsEnabled,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showRanking(
    BuildContext context,
    GameStyle style,
    GameStatistics statistics,
    bool isLoaded,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _RankingSheet(
        style: style,
        statistics: statistics,
        isLoaded: isLoaded,
      ),
    );
  }

  Future<void> _usePowerUp(
    BuildContext context,
    int cost,
    Future<bool> Function(GameCubit cubit) action,
  ) async {
    final cubit = context.read<GameCubit>();
    if (cubit.state.diamonds < cost) {
      final choice = await _showDiamondOptions(context, cost);
      if (!context.mounted || choice == null) return;

      try {
        if (choice == _DiamondOption.advertisement) {
          await _showAdvertisement(context, cubit);
          if (!context.mounted) return;
        }
        await cubit.purchaseDiamonds(_powerUpReward);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              choice == _DiamondOption.advertisement
                  ? '¡Publicidad completada! +$_powerUpReward 💎'
                  : '¡Compra demo completada! +$_powerUpReward 💎',
            ),
          ),
        );
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudieron agregar los diamantes. Intentá de nuevo.',
            ),
          ),
        );
        return;
      }
    }

    try {
      final success = await action(cubit);
      if (success || !context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo usar el poder (faltan diamantes o carta seleccionada).',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo guardar el uso del poder. Intentá de nuevo.',
          ),
        ),
      );
    }
  }

  static const _powerUpReward = 50;

  Future<_DiamondOption?> _showDiamondOptions(BuildContext context, int cost) {
    return showDialog<_DiamondOption>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Te faltan diamantes'),
        content: Text(
          'Este poder cuesta $cost 💎. Podés sumar $_powerUpReward diamantes '
          'con una compra de demostración o viendo una publicidad.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Ahora no'),
          ),
          OutlinedButton.icon(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_DiamondOption.purchase),
            icon: const Icon(Icons.diamond_rounded),
            label: const Text('Comprar (demo)'),
          ),
          FilledButton.icon(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_DiamondOption.advertisement),
            icon: const Icon(Icons.ondemand_video_rounded),
            label: const Text('Ver publicidad'),
          ),
        ],
      ),
    );
  }

  void _openDiamondShop(BuildContext context) {
    final colors = AppColors.paletteFor(
      context.read<GameCubit>().state.gameStyle,
      Theme.of(context).brightness == Brightness.dark,
    );
    final cubit = context.read<GameCubit>();

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '💎 Tienda de Diamantes',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Elegí un paquete para sumar diamantes a tu cuenta y usarlos en poderes.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Compra de demostración: no se realiza ningún cobro real.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMedium, fontSize: 12),
            ),
            const SizedBox(height: 24),
            for (final package in const [
              (diamonds: 50, price: '\$0.99'),
              (diamonds: 150, price: '\$1.99'),
              (diamonds: 400, price: '\$3.99'),
            ]) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _completeDiamondPurchase(
                    context,
                    sheetContext,
                    cubit,
                    package.diamonds,
                  ),
                  icon: const Icon(Icons.diamond_rounded),
                  label: Text(
                    '${package.diamonds} diamantes · ${package.price} (demo)',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.playfulBlue,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _completeDiamondPurchase(
    BuildContext context,
    BuildContext sheetContext,
    GameCubit cubit,
    int amount,
  ) async {
    try {
      await cubit.purchaseDiamonds(amount);
      if (!context.mounted || !sheetContext.mounted) return;
      Navigator.of(sheetContext).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Compra demo completada! +$amount 💎')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar la compra. Intentá de nuevo.'),
        ),
      );
    }
  }

  void _openProUpgrade(BuildContext context) {
    final cubit = context.read<GameCubit>();
    final palette = AppColors.paletteFor(
      cubit.state.gameStyle,
      Theme.of(context).brightness == Brightness.dark,
    );

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '⭐ Versión PRO',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Desbloqueá Pradera, Montañas y Tundra, y jugá sin publicidad. Esta es una activación de demostración, sin cobro real.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  _completeProUpgrade(context, sheetContext, cubit),
              icon: const Icon(Icons.star_rounded),
              label: const Text('Activar PRO (demo, sin cobro)'),
              style: FilledButton.styleFrom(
                backgroundColor: Color.lerp(
                  palette.secondary,
                  Colors.black,
                  0.08,
                ),
                foregroundColor: const Color(0xFF332500),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmProDowngrade(BuildContext context) async {
    final cubit = context.read<GameCubit>();
    final shouldDowngrade = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Volver a la cuenta básica'),
        content: const Text(
          'La partida actual se cerrará. Las temáticas Pradera, Montañas y Tundra se bloquearán y volverán a aparecer anuncios.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Volver a BÁSICA'),
          ),
        ],
      ),
    );
    if (!context.mounted || shouldDowngrade != true) return;

    cubit.returnToSetup();
    try {
      await cubit.downgradeToBasic();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cuenta volvió a BÁSICA.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cambiar la cuenta. Intentá de nuevo.'),
        ),
      );
    }
  }

  Future<void> _completeProUpgrade(
    BuildContext context,
    BuildContext sheetContext,
    GameCubit cubit,
  ) async {
    try {
      await cubit.upgradeToPro();
      if (!context.mounted || !sheetContext.mounted) return;
      Navigator.of(sheetContext).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Cuenta actualizada a PRO! 🌟')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo actualizar la cuenta. Intentá de nuevo.'),
        ),
      );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onThemeModeChanged,
    required this.canChangeTheme,
    required this.onOpenSettings,
  });

  final ValueChanged<bool> onThemeModeChanged;
  final bool canChangeTheme;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            final cubit = context.read<GameCubit>();
            if (cubit.state.phase == GamePhase.initial) {
              Navigator.of(context).pop();
            } else {
              cubit.returnToSetup();
            }
          },
        ),
        const Spacer(),
        const Text(
          'Memoria Animal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Configuración',
          icon: const Icon(Icons.settings_rounded),
          onPressed: onOpenSettings,
        ),
        if (canChangeTheme)
          _ThemeModeSwitch(
            isDarkMode: Theme.of(context).brightness == Brightness.dark,
            onChanged: onThemeModeChanged,
          ),
      ],
    );
  }
}

class _ThemeModeSwitch extends StatelessWidget {
  const _ThemeModeSwitch({required this.isDarkMode, required this.onChanged});

  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.paletteFor(
      context.read<GameCubit>().state.gameStyle,
      isDarkMode,
    );

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.panelBorder, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeModeButton(
            icon: Icons.light_mode_rounded,
            tooltip: 'Modo claro',
            selected: !isDarkMode,
            selectedColor: colors.secondary,
            onPressed: () => onChanged(false),
          ),
          _ThemeModeButton(
            icon: Icons.dark_mode_rounded,
            tooltip: 'Modo oscuro',
            selected: isDarkMode,
            selectedColor: colors.primaryDark,
            onPressed: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeButton extends StatelessWidget {
  const _ThemeModeButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.selectedColor,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.paletteFor(
      context.read<GameCubit>().state.gameStyle,
      Theme.of(context).brightness == Brightness.dark,
    );
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, size: 18),
        style: IconButton.styleFrom(
          foregroundColor: colors.textDark,
          backgroundColor: selected ? selectedColor : Colors.transparent,
          fixedSize: const Size(34, 32),
          padding: EdgeInsets.zero,
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}

class _GameSetup extends StatelessWidget {
  const _GameSetup({
    required this.state,
    required this.onSelectDifficulty,
    required this.onClearDifficulty,
    required this.onSelectLevel,
    required this.onSelectStyle,
    required this.onStart,
    required this.onOpenRanking,
    required this.isDark,
  });

  final GameState state;
  final ValueChanged<GameDifficulty> onSelectDifficulty;
  final VoidCallback onClearDifficulty;
  final ValueChanged<GameLevel> onSelectLevel;
  final ValueChanged<GameStyle> onSelectStyle;
  final VoidCallback onStart;
  final VoidCallback onOpenRanking;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.paletteFor(state.gameStyle, isDark);
    final selectedButtonColor = isDark
        ? Color.lerp(colors.primaryDark, Colors.black, 0.35)!
        : colors.primaryDark;
    final tundraButtonColor = Color.lerp(
      selectedButtonColor,
      Colors.black,
      isDark ? 0.16 : 0.18,
    )!;
    final rankingButtonColor = state.gameStyle == GameStyle.tundra && isDark
        ? const Color(0xFF0D47A1)
        : colors.primaryDark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Elegí la temática',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final chipWidth = (constraints.maxWidth - 24) / 4;
                  final styles = GameStyle.values;

                  Widget buildStyleChip(GameStyle style) {
                    final isLocked =
                        _requiresPro(style) && state.accountType != 'PRO';
                    return SizedBox(
                      width: chipWidth,
                      height: 44,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          SizedBox.expand(
                            child: ChoiceChip(
                              showCheckmark: false,
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    style.emoji,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      style.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              selected: state.gameStyle == style,
                              onSelected: (_) => onSelectStyle(style),
                              selectedColor: style == GameStyle.tundra
                                  ? tundraButtonColor
                                  : selectedButtonColor,
                              backgroundColor: colors.panel,
                              labelStyle: TextStyle(
                                color: state.gameStyle == style
                                    ? Colors.white
                                    : colors.textDark,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          if (isLocked)
                            Positioned(
                              top: -3,
                              right: 8,
                              child: IgnorePointer(
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: colors.panel,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colors.panelBorder,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.lock_rounded,
                                    size: 10,
                                    color: colors.textMedium,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final style in styles.take(4))
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: buildStyleChip(style),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final style in styles.skip(4))
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: buildStyleChip(style),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: state.difficulty == null
                    ? Column(
                        key: const ValueKey('difficulty-step'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Elegí la dificultad',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'La dificultad cambia el tiempo para mirar las cartas.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.textDark),
                          ),
                          const SizedBox(height: 12),
                          if (!state.scoresLoaded)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else
                            for (final difficulty in GameDifficulty.values)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: SizedBox(
                                  height: 64,
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        onSelectDifficulty(difficulty),
                                    style: OutlinedButton.styleFrom(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      backgroundColor: colors.panel,
                                      foregroundColor: colors.textDark,
                                      side: BorderSide(
                                        color: colors.panelBorder,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            difficulty.label,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Total ${state.scores[difficulty] ?? 0}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.star_rounded,
                                          size: 20,
                                          color: colors.secondaryDark,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      )
                    : Column(
                        key: const ValueKey('level-step'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                tooltip: 'Cambiar dificultad',
                                onPressed: onClearDifficulty,
                                icon: const Icon(Icons.arrow_back_rounded),
                                color: colors.primaryDark,
                              ),
                              Expanded(
                                child: Text(
                                  'Dificultad ${state.difficulty!.label}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colors.textDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                          Text(
                            '¡Ahora elegí tu nivel!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (final level in GameLevel.values)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _LevelChoiceCard(
                                level: level,
                                isSelected: state.level == level,
                                color: selectedButtonColor,
                                panelColor: colors.panel,
                                borderColor: colors.panelBorder,
                                textColor: colors.textDark,
                                onTap: () => onSelectLevel(level),
                              ),
                            ),
                        ],
                      ),
              ),
              if (state.selectionRequired) ...[
                const SizedBox(height: 2),
                const Text(
                  'Tenés que seleccionar una dificultad para empezar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 4),
              OutlinedButton.icon(
                onPressed: onOpenRanking,
                icon: const Icon(Icons.emoji_events_rounded),
                label: const Text('Ver ranking y estadísticas'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: rankingButtonColor,
                  side: BorderSide(color: rankingButtonColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 4),
              if (state.difficulty != null)
                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: state.scoresLoaded && state.statisticsLoaded
                        ? onStart
                        : null,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text('¡Jugar ${state.level.label}!'),
                    style: FilledButton.styleFrom(
                      backgroundColor: state.gameStyle == GameStyle.tundra
                          ? tundraButtonColor
                          : selectedButtonColor,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelChoiceCard extends StatelessWidget {
  const _LevelChoiceCard({
    required this.level,
    required this.isSelected,
    required this.color,
    required this.panelColor,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
  });

  final GameLevel level;
  final bool isSelected;
  final Color color;
  final Color panelColor;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isSelected ? Colors.white : textColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : panelColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? color : borderColor,
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Text(level.emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.label,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      level.description,
                      style: TextStyle(color: foregroundColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${level.pairsCount} pares',
                    style: TextStyle(
                      color: foregroundColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${level.pairsCount * 2} cartas',
                    style: TextStyle(color: foregroundColor, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankingSheet extends StatelessWidget {
  const _RankingSheet({
    required this.style,
    required this.statistics,
    required this.isLoaded,
  });

  final GameStyle style;
  final GameStatistics statistics;
  final bool isLoaded;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.paletteFor(
      style,
      Theme.of(context).brightness == Brightness.dark,
    );
    final maxHeight = MediaQuery.sizeOf(context).height * 0.82;

    return SafeArea(
      child: SizedBox(
        height: maxHeight,
        child: DefaultTabController(
          length: 3,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events_rounded,
                      color: colors.secondaryDark,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ranking general',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: colors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Récords de todas las categorías y dificultades',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textMedium, fontSize: 12),
                ),
                const SizedBox(height: 8),
                TabBar(
                  labelColor: colors.primaryDark,
                  unselectedLabelColor: colors.textMedium,
                  indicatorColor: colors.primaryDark,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                  tabs: const [
                    Tab(text: 'Resumen'),
                    Tab(text: 'Intentos'),
                    Tab(text: 'Tiempo'),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: !isLoaded
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          children: [
                            _RankingSummary(
                              statistics: statistics,
                              colors: colors,
                            ),
                            _LeaderboardSection(
                              title: 'Menos intentos',
                              subtitle: 'Partidas ganadas con menos intentos',
                              icon: Icons.touch_app_rounded,
                              records: statistics.fewestMovesWins,
                              colors: colors,
                              valueForRecord: (record) =>
                                  '${record.moves} intentos',
                            ),
                            _LeaderboardSection(
                              title: 'Menor tiempo',
                              subtitle: 'Partidas ganadas más rápido',
                              icon: Icons.timer_rounded,
                              records: statistics.fastestWins,
                              colors: colors,
                              valueForRecord: (record) =>
                                  _formatRankingTime(record.seconds),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatRankingTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class _RankingSummary extends StatelessWidget {
  const _RankingSummary({required this.statistics, required this.colors});

  final GameStatistics statistics;
  final AppPalette colors;

  @override
  Widget build(BuildContext context) {
    final styles = GameStyle.values;
    final difficulties = GameDifficulty.values;
    final levels = GameLevel.values;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatisticsTotal(totalPlayed: statistics.totalPlayed, colors: colors),
          const SizedBox(height: 10),
          _SummaryCard(
            title: 'Partidas por categoría',
            icon: Icons.pets_rounded,
            colors: colors,
            child: Column(
              children: [
                for (var index = 0; index < styles.length; index += 2)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(
                          child: _CompactStatistic(
                            emoji: styles[index].emoji,
                            label: styles[index].label,
                            count: statistics.playsByStyle[styles[index]] ?? 0,
                            colors: colors,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (index + 1 < styles.length)
                          Expanded(
                            child: _CompactStatistic(
                              emoji: styles[index + 1].emoji,
                              label: styles[index + 1].label,
                              count:
                                  statistics.playsByStyle[styles[index + 1]] ??
                                  0,
                              colors: colors,
                            ),
                          )
                        else
                          const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _SummaryCard(
            title: 'Partidas por dificultad',
            icon: Icons.stars_rounded,
            colors: colors,
            child: Row(
              children: [
                for (final difficulty in difficulties)
                  Expanded(
                    child: _CompactStatistic(
                      emoji: '⭐',
                      label: difficulty.label,
                      count: statistics.playsByDifficulty[difficulty] ?? 0,
                      colors: colors,
                      centered: true,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _SummaryCard(
            title: 'Intentos por nivel',
            icon: Icons.flag_rounded,
            colors: colors,
            child: Column(
              children: [
                Text(
                  'Partidas iniciadas en cada nivel',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textMedium, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (final level in levels)
                      Expanded(
                        child: _CompactStatistic(
                          emoji: level.emoji,
                          label: level.label,
                          count: statistics.playsByLevel[level] ?? 0,
                          colors: colors,
                          centered: true,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticsTotal extends StatelessWidget {
  const _StatisticsTotal({required this.totalPlayed, required this.colors});

  final int totalPlayed;
  final AppPalette colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.panelBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_esports_rounded, color: colors.primaryDark),
          const SizedBox(width: 10),
          Text(
            'Partidas jugadas: $totalPlayed',
            style: TextStyle(
              color: colors.textDark,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.icon,
    required this.colors,
    required this.child,
  });

  final String title;
  final IconData icon;
  final AppPalette colors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.primaryDark, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: colors.textDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          child,
        ],
      ),
    );
  }
}

class _CompactStatistic extends StatelessWidget {
  const _CompactStatistic({
    required this.emoji,
    required this.label,
    required this.count,
    required this.colors,
    this.centered = false,
  });

  final String emoji;
  final String label;
  final int count;
  final AppPalette colors;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: centered
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textDark, fontSize: 12),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            color: colors.textDark,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _LeaderboardSection extends StatelessWidget {
  const _LeaderboardSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.records,
    required this.colors,
    required this.valueForRecord,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<GameRecord> records;
  final AppPalette colors;
  final String Function(GameRecord record) valueForRecord;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.primaryDark, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.textDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(color: colors.textMedium, fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (records.isEmpty)
            Text(
              '¡Ganate un lugar en el ranking!',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMedium),
            )
          else
            for (var index = 0; index < records.length && index < 5; index++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: colors.primary.withValues(alpha: 0.18),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: colors.textDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${records[index].style.emoji} '
                        '${records[index].style.label} · '
                        '${records[index].difficulty.label} · '
                        '${records[index].level.label}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.textDark, fontSize: 12),
                      ),
                    ),
                    Text(
                      valueForRecord(records[index]),
                      style: TextStyle(
                        color: colors.primaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _GameControlBar extends StatelessWidget {
  const _GameControlBar({
    required this.state,
    required this.onPause,
    required this.onRestart,
    required this.onNewGame,
  });

  final GameState state;

  final VoidCallback onPause;
  final VoidCallback onRestart;
  final VoidCallback onNewGame;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.paletteFor(
      state.gameStyle,
      Theme.of(context).brightness == Brightness.dark,
    );
    final canPause = state.phase == GamePhase.playing && !state.isResolving;
    final canRestart = state.cards.isNotEmpty;
    final canNewGame = state.phase != GamePhase.initial;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      children: [
        if (canPause)
          _GameControlButton(
            icon: Icons.pause_rounded,
            tooltip: 'Pausar partida',
            color: colors.playfulBlue,
            onPressed: onPause,
          ),
        if (canRestart)
          _GameControlButton(
            icon: Icons.replay_rounded,
            tooltip: 'Reiniciar partida',
            color: const Color(0xFFFF725E),
            onPressed: onRestart,
          ),
        if (canNewGame)
          _GameControlButton(
            icon: Icons.shuffle_rounded,
            tooltip: 'Nueva partida',
            color: colors.lavender,
            onPressed: onNewGame,
          ),
      ],
    );
  }
}

class _GameControlButton extends StatelessWidget {
  const _GameControlButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({
    required this.state,
    required this.onOpenShop,
    required this.onUpgradeAccount,
    required this.onDowngradeAccount,
  });

  final GameState state;
  final VoidCallback onOpenShop;
  final VoidCallback onUpgradeAccount;
  final VoidCallback onDowngradeAccount;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.paletteFor(
      state.gameStyle,
      Theme.of(context).brightness == Brightness.dark,
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.panel,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.panelBorder, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👤', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                state.username,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.textDark,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.secondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  state.accountType,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: colors.secondaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.panel,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.panelBorder, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, size: 16, color: Colors.amber),
              const SizedBox(width: 6),
              Text(
                'Puntaje ${state.score}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.textDark,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onOpenShop,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.panel,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.panelBorder, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💎', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '${state.diamonds}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.textDark,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.add_circle_rounded,
                  size: 18,
                  color: colors.primaryDark,
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: state.accountType == 'PRO'
              ? onDowngradeAccount
              : onUpgradeAccount,
          tooltip: state.accountType == 'PRO'
              ? 'Volver a BÁSICA'
              : 'Pasar a PRO',
          icon: Icon(
            state.accountType == 'PRO'
                ? Icons.undo_rounded
                : Icons.star_rounded,
            color: state.accountType == 'PRO'
                ? colors.secondaryDark
                : Colors.amber,
          ),
          style: IconButton.styleFrom(backgroundColor: colors.panel),
        ),
      ],
    );
  }
}

class _PowerUpBar extends StatelessWidget {
  const _PowerUpBar({
    required this.enabled,
    required this.onRevealCard,
    required this.onFindPair,
    required this.onAddTime,
  });

  final bool enabled;
  final VoidCallback onRevealCard;
  final VoidCallback onFindPair;
  final VoidCallback onAddTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PowerUpButton(
          emoji: '💡',
          label: '${GameCubit.revealCardCost}',
          tooltip: 'Ver una carta (15 💎)',
          enabled: enabled,
          onPressed: onRevealCard,
        ),
        const SizedBox(width: 12),
        _PowerUpButton(
          emoji: '✨',
          label: '${GameCubit.findPairCost}',
          tooltip: 'Encontrar par (40 💎)',
          enabled: enabled,
          onPressed: onFindPair,
        ),
        const SizedBox(width: 12),
        _PowerUpButton(
          emoji: '⏳',
          label: '${GameCubit.extraTimeCost}',
          tooltip: 'Añadir 30s (25 💎)',
          enabled: enabled,
          onPressed: onAddTime,
        ),
      ],
    );
  }
}

class _PowerUpButton extends StatelessWidget {
  const _PowerUpButton({
    required this.emoji,
    required this.label,
    required this.tooltip,
    required this.enabled,
    required this.onPressed,
  });

  final String emoji;
  final String label;
  final String tooltip;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: FilledButton.tonal(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PairEncouragementOverlay extends StatelessWidget {
  const _PairEncouragementOverlay();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
