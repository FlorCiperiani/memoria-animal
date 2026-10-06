import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_durations.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/memory_card.dart';

class MemoryCardWidget extends StatelessWidget {
  const MemoryCardWidget({
    required this.card,
    required this.onTap,
    this.isStarred = false,
    super.key,
  });

  final MemoryCard card;
  final VoidCallback onTap;
  final bool isStarred;

  @override
  Widget build(BuildContext context) {
    final isMatched = card.isMatched;

    return IgnorePointer(
      ignoring: isMatched,
      child: AnimatedScale(
        scale: isMatched ? 0 : 1,
        duration: AppDurations.cardDisappear,
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: isMatched ? 0 : 1,
          duration: AppDurations.cardDisappear,
          child: GestureDetector(
            onTap: onTap,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: card.isFaceUp ? 1 : 0),
              duration: AppDurations.cardFlip,
              curve: Curves.easeInOut,
              builder: (context, value, _) {
                final showFront = value >= 0.5;

                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(value * math.pi),
                  child: showFront
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: _CardFront(card: card),
                        )
                      : _CardBack(isStarred: isStarred),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.isStarred});

  final bool isStarred;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.cardBack, colors.playfulBlue.withValues(alpha: 0.82)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.75),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.playfulBlue.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(Icons.pets_rounded, color: Colors.white, size: 38),
          ),
          if (isStarred)
            const Positioned(
              top: 8,
              right: 10,
              child: Icon(Icons.star_rounded, color: Colors.amber, size: 26),
            ),
        ],
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({required this.card});

  final MemoryCard card;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isMismatch = card.status == CardStatus.mismatched;
    final pairColors = Theme.of(context).brightness == Brightness.dark
        ? const [
            Color(0xFF34496B),
            Color(0xFF4B385E),
            Color(0xFF31584F),
            Color(0xFF624652),
            Color(0xFF665334),
            Color(0xFF38566B),
          ]
        : [
            colors.cardFront,
            const Color(0xFFBDEBFF),
            const Color(0xFFFFC9D5),
            const Color(0xFFC6F0C7),
            const Color(0xFFE1D5FF),
            const Color(0xFFFFD4A6),
          ];
    final faceColor = isMismatch
        ? colors.mismatchBackground
        : pairColors[card.pairId % pairColors.length];

    return AnimatedContainer(
      duration: AppDurations.cardColor,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [faceColor, faceColor.withValues(alpha: 0.82)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isMismatch
              ? colors.mismatch
              : colors.textDark.withValues(alpha: 0.18),
          width: isMismatch ? 2.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: FittedBox(
                  child: Text(
                    card.symbol,
                    style: const TextStyle(fontSize: 58),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 16,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  card.animalName,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF33415C),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
