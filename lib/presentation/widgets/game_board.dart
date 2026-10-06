import 'package:flutter/material.dart';

import '../../domain/entities/memory_card.dart';
import 'memory_card_widget.dart';

/// Grilla de fichas que se adapta al espacio disponible sin hacer scroll.
class GameBoard extends StatelessWidget {
  const GameBoard({
    required this.cards,
    required this.onCardTap,
    this.starCardId,
    super.key,
  });

  final List<MemoryCard> cards;
  final ValueChanged<int> onCardTap;
  final int? starCardId;

  static const double _spacing = 6;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > constraints.maxHeight ? 4 : 3;
        final rows = (cards.length / columns).ceil();

        final cellWidth =
            (constraints.maxWidth - _spacing * (columns - 1)) / columns;
        final cellHeight =
            (constraints.maxHeight - _spacing * (rows - 1)) / rows;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: _spacing,
            crossAxisSpacing: _spacing,
            childAspectRatio: cellWidth / cellHeight,
          ),
          itemBuilder: (context, index) {
            final card = cards[index];
            return MemoryCardWidget(
              key: ValueKey(card.id),
              card: card,
              isStarred: card.id == starCardId,
              onTap: () => onCardTap(card.id),
            );
          },
        );
      },
    );
  }
}
