import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/memory_card.dart';
import '../games/animal_memory_game.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({
    required this.cards,
    required this.onCardTap,
    this.starCardId,
    super.key,
  });

  final List<MemoryCard> cards;
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
      colors: _colors,
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

  AppPalette get _colors => AppColors.light;
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

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
                final columns = constraints.maxWidth > constraints.maxHeight
                    ? 4
                    : 3;
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
                    childAspectRatio: cellWidth / cellHeight,
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
