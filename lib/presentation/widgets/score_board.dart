import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ScoreBoard extends StatelessWidget {
  const ScoreBoard({
    required this.moves,
    required this.matchedPairs,
    required this.totalPairs,
    required this.remainingSeconds,
    super.key,
  });

  final int moves;
  final int matchedPairs;
  final int totalPairs;
  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : colors.textDark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          icon: Icons.touch_app_rounded,
          label: 'Intentos',
          value: '$moves',
          color: colors.playfulBlue,
          textColor: textColor,
        ),
        _StatItem(
          icon: Icons.favorite_rounded,
          label: 'Pares',
          value: '$matchedPairs/$totalPairs',
          color: colors.primaryDark,
          textColor: textColor,
        ),
        _StatItem(
          icon: Icons.timer_outlined,
          label: 'Tiempo',
          value: _formatTime(remainingSeconds),
          isUrgent: remainingSeconds <= 15,
          color: colors.playfulMint,
          textColor: textColor,
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;

    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
    this.isUrgent = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color textColor;
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final iconColor = isUrgent ? colors.primaryDark : color;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
