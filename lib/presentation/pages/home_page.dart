import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_surfaces.dart';
import 'game_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.onThemeModeChanged, super.key});

  final ValueChanged<bool> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      body: AppBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: PlayfulPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 42,
                  ),
                  borderRadius: 28,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // =================================================
                      // ICONOS
                      // =================================================

                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colors.secondary,
                              colors.primary,
                              colors.lavender,
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.75),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.28),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Text(
                          '🐯🐸🐼',
                          style: TextStyle(fontSize: 38),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // =================================================
                      // TÍTULO
                      // =================================================
                      Text(
                        'Memoria Animal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: colors.textDark,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        '¡Encontrá las parejas de animales!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: colors.textMedium,
                        ),
                      ),

                      const SizedBox(height: 34),

                      // =================================================
                      // BOTÓN JUGAR
                      // =================================================
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => GamePage(
                                  onThemeModeChanged: onThemeModeChanged,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('¡Jugar!'),
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primaryDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            elevation: 0,
                            shadowColor: colors.primaryDark.withValues(
                              alpha: 0.22,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pets_rounded,
                            size: 16,
                            color: colors.secondaryDark,
                          ),
                          SizedBox(width: 7),
                          Text(
                            '🐶  🦊  🐰  🐻',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
