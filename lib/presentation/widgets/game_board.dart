import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/game_style.dart';
import '../../domain/entities/memory_card.dart';
import '../games/animal_memory_game.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({
    required this.cards,
    required this.gameStyle,
    required this.onCardTap,
    this.starCardId,
    super.key,
  });

  final List<MemoryCard> cards;
  final GameStyle gameStyle;
  final ValueChanged<int> onCardTap;
  final int? starCardId;

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late final AnimalMemoryGame _game;

  @override
  void initState() {
    super.initState();
    _game = AnimalMemoryGame(
      cards: widget.cards,
      starCardId: widget.starCardId,
      colors: AppColors.paletteFor(widget.gameStyle, false),
      isDark: false,
      onCardTap: widget.onCardTap,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateGame();
  }

  @override
  void didUpdateWidget(covariant GameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateGame();
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  AppPalette get _colors => AppColors.paletteFor(widget.gameStyle, _isDark);

  void _updateGame() {
    if (!mounted) return;
    _game.updateBoard(
      cards: widget.cards,
      starCardId: widget.starCardId,
      colors: _colors,
      isDark: _isDark,
      onCardTap: widget.onCardTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: [
        Positioned.fill(
          child: GameWidget<AnimalMemoryGame>(
            game: _game,
            backgroundBuilder: (_) => const SizedBox.expand(),
          ),
        ),
        Positioned.fill(
          child: _SemanticsOnly(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const columns = 4;
                final rows = (widget.cards.length / columns).ceil();
                final cellWidth =
                    (constraints.maxWidth - 6 * (columns - 1)) / columns;
                final cellHeight =
                    (constraints.maxHeight - 6 * (rows - 1)) / rows;

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.cards.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: widget.cards.length <= 6
                        ? 1.45
                        : (cellWidth / cellHeight).clamp(0.7, 1.2),
                  ),
                  itemBuilder: (context, index) {
                    final card = widget.cards[index];
                    return Semantics(
                      label: card.isFaceUp
                          ? '${card.symbol}, ${card.animalName}'
                          : 'Carta boca abajo',
                      button: !card.isMatched,
                      onTap: card.isMatched
                          ? null
                          : () => widget.onCardTap(card.id),
                      child: const SizedBox.expand(),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SemanticsOnly extends SingleChildRenderObjectWidget {
  const _SemanticsOnly({required super.child});

  @override
  RenderProxyBox createRenderObject(BuildContext context) {
    return _SemanticsOnlyRenderProxyBox();
  }
}

class _SemanticsOnlyRenderProxyBox extends RenderProxyBox {
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) => false;
}
