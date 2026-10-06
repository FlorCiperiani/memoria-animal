import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/game_style.dart';
import 'app_colors.dart';

class AppBackdrop extends StatefulWidget {
  const AppBackdrop({required this.child, this.gameStyle, super.key});

  final Widget child;
  final GameStyle? gameStyle;

  @override
  State<AppBackdrop> createState() => _AppBackdropState();
}

class _AppBackdropState extends State<AppBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _twinkle = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    if (isDark && !reduceMotion) {
      if (!_twinkle.isAnimating) _twinkle.repeat();
    } else {
      _twinkle.stop();
    }
  }

  @override
  void dispose() {
    _twinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = widget.gameStyle ?? GameStyle.classic;
    final colors = AppColors.paletteFor(style, isDark);

    CustomPainter backdropPainter = switch (style) {
      GameStyle.classic =>
        isDark ? _NightSkyPainter(twinkle: _twinkle) : _CloudPainter(colors),
      GameStyle.desert => _DesertPainter(isDark: isDark, twinkle: _twinkle),
      GameStyle.jungle => _JunglePainter(isDark: isDark, twinkle: _twinkle),
      GameStyle.savanna => _SavannaPainter(isDark: isDark, twinkle: _twinkle),
      GameStyle.forest => _ForestPainter(isDark: isDark, twinkle: _twinkle),
      GameStyle.prairie ||
      GameStyle.mountains ||
      GameStyle.tundra => _LandscapePainter(
        gameStyle: style,
        isDark: isDark,
        colors: colors,
        twinkle: _twinkle,
      ),
    };

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.backgroundTop,
                colors.background,
                colors.backgroundBottom,
              ],
              stops: const [0.0, 0.58, 1.0],
            ),
          ),
        ),

        Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: backdropPainter)),
        ),

        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _PlayfulConfettiPainter(colors)),
          ),
        ),

        widget.child,
      ],
    );
  }
}

class _LandscapePainter extends CustomPainter {
  const _LandscapePainter({
    required this.gameStyle,
    required this.isDark,
    required this.colors,
    required this.twinkle,
  });

  final GameStyle gameStyle;
  final bool isDark;
  final AppPalette colors;
  final Animation<double> twinkle;

  @override
  void paint(Canvas canvas, Size size) {
    if (isDark) {
      _NightSkyPainter(twinkle: twinkle).paint(canvas, size);
    } else {
      _CloudPainter(colors).paint(canvas, size);
    }

    switch (gameStyle) {
      case GameStyle.prairie:
        _paintPrairie(canvas, size);
      case GameStyle.mountains:
        _paintMountains(canvas, size);
      case GameStyle.tundra:
        _paintTundra(canvas, size);
      default:
        break;
    }
  }

  void _paintPrairie(Canvas canvas, Size size) {
    final grass = Paint()
      ..color = (isDark ? const Color(0xFF476B39) : const Color(0xFF7DAD4E))
          .withValues(alpha: isDark ? 1 : 0.45);
    final ground = Paint()
      ..color = (isDark ? const Color(0xFF273D27) : const Color(0xFFB3C96A))
          .withValues(alpha: isDark ? 1 : 0.4);
    final hill = Path()
      ..moveTo(0, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.44,
        size.height * 0.67,
        size.width,
        size.height * 0.77,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hill, ground);

    for (var i = 0; i < 22; i++) {
      final x = size.width * ((i * 37 % 101) / 100);
      final y = size.height * (0.77 + (i % 4) * 0.035);
      canvas.drawLine(
        Offset(x, y),
        Offset(x + (i.isEven ? 5 : -5), y - 12 - (i % 3) * 4),
        grass
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _paintMountains(Canvas canvas, Size size) {
    final farPaint = Paint()
      ..color = (isDark ? const Color(0xFF34445C) : const Color(0xFF8FA9B8))
          .withValues(alpha: isDark ? 1 : 0.32);
    final nearPaint = Paint()
      ..color = (isDark ? const Color(0xFF26384A) : const Color(0xFF718D7F))
          .withValues(alpha: isDark ? 1 : 0.42);
    final snowPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.85 : 0.65);
    final farPeak = Path()
      ..moveTo(size.width * 0.28, size.height * 0.3)
      ..lineTo(size.width * 0.02, size.height * 0.78)
      ..lineTo(size.width * 0.62, size.height * 0.78)
      ..close();
    final nearPeak = Path()
      ..moveTo(size.width * 0.69, size.height * 0.18)
      ..lineTo(size.width * 0.34, size.height * 0.82)
      ..lineTo(size.width * 1.05, size.height * 0.82)
      ..close();
    canvas
      ..drawPath(farPeak, farPaint)
      ..drawPath(nearPeak, nearPaint)
      ..drawPath(
        Path()
          ..moveTo(size.width * 0.28, size.height * 0.3)
          ..lineTo(size.width * 0.19, size.height * 0.47)
          ..lineTo(size.width * 0.31, size.height * 0.42)
          ..lineTo(size.width * 0.39, size.height * 0.49)
          ..close(),
        snowPaint,
      )
      ..drawPath(
        Path()
          ..moveTo(size.width * 0.69, size.height * 0.18)
          ..lineTo(size.width * 0.57, size.height * 0.4)
          ..lineTo(size.width * 0.71, size.height * 0.35)
          ..lineTo(size.width * 0.82, size.height * 0.45)
          ..close(),
        snowPaint,
      );
  }

  void _paintTundra(Canvas canvas, Size size) {
    final snow = Paint()
      ..color = (isDark ? const Color(0xFFB6CED9) : const Color(0xFFE8F4F4))
          .withValues(alpha: isDark ? 1 : 0.42);
    final ice = Paint()
      ..color = (isDark ? const Color(0xFF6F9BAC) : const Color(0xFF8FC9D2))
          .withValues(alpha: isDark ? 1 : 0.34);
    final bank = Path()
      ..moveTo(0, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.69,
        size.width * 0.52,
        size.height * 0.79,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.88,
        size.width,
        size.height * 0.75,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final iceberg = Path()
      ..moveTo(size.width * 0.73, size.height * 0.77)
      ..lineTo(size.width * 0.82, size.height * 0.59)
      ..lineTo(size.width * 0.9, size.height * 0.72)
      ..lineTo(size.width * 0.96, size.height * 0.64)
      ..lineTo(size.width, size.height * 0.78)
      ..close();
    canvas
      ..drawPath(bank, snow)
      ..drawPath(iceberg, ice);
  }

  @override
  bool shouldRepaint(covariant _LandscapePainter oldDelegate) =>
      oldDelegate.gameStyle != gameStyle || oldDelegate.isDark != isDark;
}

// ================================================================
// PINTORES TEMÁTICOS: Desierto, Selva, Sabana, Bosque (con nubes/cielo base)
// ================================================================

class _DesertPainter extends CustomPainter {
  const _DesertPainter({required this.isDark, required this.twinkle});
  final bool isDark;
  final Animation<double> twinkle;

  @override
  void paint(Canvas canvas, Size size) {
    if (isDark) {
      _NightSkyPainter(twinkle: twinkle).paint(canvas, size);
    } else {
      _CloudPainter(
        const AppPalette(
          backgroundTop: Colors.transparent,
          background: Colors.transparent,
          backgroundBottom: Colors.transparent,
          primary: Colors.transparent,
          primaryDark: Colors.transparent,
          secondary: Colors.transparent,
          secondaryDark: Colors.transparent,
          playfulBlue: Colors.transparent,
          playfulMint: Colors.transparent,
          panel: Colors.transparent,
          panelBorder: Colors.transparent,
          cardBack: Colors.transparent,
          cardFront: Colors.transparent,
          mismatch: Colors.transparent,
          mismatchBackground: Colors.transparent,
          textDark: Colors.transparent,
          textMedium: Colors.transparent,
          textLight: Colors.transparent,
          lavender: Colors.transparent,
        ),
      ).paint(canvas, size);
    }

    final dunePaint = Paint()
      ..color = (isDark ? const Color(0xFF3D261B) : const Color(0xFFE69A32))
          .withValues(alpha: isDark ? 1 : 0.3);
    final cactusPaint = Paint()
      ..color = (isDark ? const Color(0xFF1E3A2F) : const Color(0xFF2E7D32))
          .withValues(alpha: isDark ? 1 : 0.55);

    final path = Path()
      ..moveTo(0, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.70,
        size.width * 0.8,
        size.height * 0.82,
      )
      ..quadraticBezierTo(
        size.width * 0.92,
        size.height * 0.86,
        size.width,
        size.height * 0.8,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, dunePaint);

    _drawDetailedCactus(
      canvas,
      Offset(size.width * 0.82, size.height * 0.65),
      cactusPaint,
    );
  }

  void _drawDetailedCactus(Canvas canvas, Offset pos, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx, pos.dy, 16, 90),
        const Radius.circular(8),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx - 22, pos.dy + 30, 22, 12),
        const Radius.circular(6),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx - 22, pos.dy + 15, 12, 25),
        const Radius.circular(6),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx + 16, pos.dy + 45, 24, 12),
        const Radius.circular(6),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx + 28, pos.dy + 25, 12, 30),
        const Radius.circular(6),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DesertPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _JunglePainter extends CustomPainter {
  const _JunglePainter({required this.isDark, required this.twinkle});
  final bool isDark;
  final Animation<double> twinkle;

  @override
  void paint(Canvas canvas, Size size) {
    if (isDark) {
      _NightSkyPainter(twinkle: twinkle).paint(canvas, size);
    } else {
      _CloudPainter(
        const AppPalette(
          backgroundTop: Colors.transparent,
          background: Colors.transparent,
          backgroundBottom: Colors.transparent,
          primary: Colors.transparent,
          primaryDark: Colors.transparent,
          secondary: Colors.transparent,
          secondaryDark: Colors.transparent,
          playfulBlue: Colors.transparent,
          playfulMint: Colors.transparent,
          panel: Colors.transparent,
          panelBorder: Colors.transparent,
          cardBack: Colors.transparent,
          cardFront: Colors.transparent,
          mismatch: Colors.transparent,
          mismatchBackground: Colors.transparent,
          textDark: Colors.transparent,
          textMedium: Colors.transparent,
          textLight: Colors.transparent,
          lavender: Colors.transparent,
        ),
      ).paint(canvas, size);
    }

    final vinePaint = Paint()
      ..color = (isDark ? const Color(0xFF2E7D32) : const Color(0xFF2E7D32))
          .withValues(alpha: isDark ? 1 : 0.6)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final leafPaint = Paint()
      ..color = (isDark ? const Color(0xFF388E3C) : const Color(0xFF4CAF50))
          .withValues(alpha: isDark ? 1 : 0.85);

    // Solo las 2 lianas de los lados (sin la del medio)
    final v1 = Path()
      ..moveTo(size.width * 0.2, 0)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.2,
        size.width * 0.15,
        size.height * 0.4,
        size.width * 0.22,
        size.height * 0.65,
      );
    canvas.drawPath(v1, vinePaint);

    final v2 = Path()
      ..moveTo(size.width * 0.78, 0)
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.25,
        size.width * 0.82,
        size.height * 0.45,
        size.width * 0.75,
        size.height * 0.7,
      );
    canvas.drawPath(v2, vinePaint);

    // Hojas en las lianas laterales
    _drawLeaf(canvas, Offset(size.width * 0.22, size.height * 0.15), leafPaint);
    _drawLeaf(canvas, Offset(size.width * 0.18, size.height * 0.30), leafPaint);
    _drawLeaf(canvas, Offset(size.width * 0.17, size.height * 0.45), leafPaint);
    _drawLeaf(canvas, Offset(size.width * 0.20, size.height * 0.55), leafPaint);

    _drawLeaf(canvas, Offset(size.width * 0.75, size.height * 0.20), leafPaint);
    _drawLeaf(canvas, Offset(size.width * 0.80, size.height * 0.35), leafPaint);
    _drawLeaf(canvas, Offset(size.width * 0.78, size.height * 0.50), leafPaint);
    _drawLeaf(canvas, Offset(size.width * 0.76, size.height * 0.62), leafPaint);
  }

  void _drawLeaf(Canvas canvas, Offset center, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    final path = Path()
      ..moveTo(0, -10)
      ..quadraticBezierTo(14, -5, 0, 14)
      ..quadraticBezierTo(-14, -5, 0, -10);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _JunglePainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _SavannaPainter extends CustomPainter {
  const _SavannaPainter({required this.isDark, required this.twinkle});
  final bool isDark;
  final Animation<double> twinkle;

  @override
  void paint(Canvas canvas, Size size) {
    if (isDark) {
      _NightSkyPainter(twinkle: twinkle).paint(canvas, size);
    } else {
      _CloudPainter(
        const AppPalette(
          backgroundTop: Colors.transparent,
          background: Colors.transparent,
          backgroundBottom: Colors.transparent,
          primary: Colors.transparent,
          primaryDark: Colors.transparent,
          secondary: Colors.transparent,
          secondaryDark: Colors.transparent,
          playfulBlue: Colors.transparent,
          playfulMint: Colors.transparent,
          panel: Colors.transparent,
          panelBorder: Colors.transparent,
          cardBack: Colors.transparent,
          cardFront: Colors.transparent,
          mismatch: Colors.transparent,
          mismatchBackground: Colors.transparent,
          textDark: Colors.transparent,
          textMedium: Colors.transparent,
          textLight: Colors.transparent,
          lavender: Colors.transparent,
        ),
      ).paint(canvas, size);
    }

    final trunkPaint = Paint()
      ..color = (isDark ? const Color(0xFF2D1B14) : const Color(0xFF4A3525))
          .withValues(alpha: isDark ? 1 : 0.65);
    final foliagePaint = Paint()
      ..color = (isDark ? const Color(0xFF1E3A20) : const Color(0xFF558B2F))
          .withValues(alpha: isDark ? 1 : 0.6);

    final groundPaint = Paint()
      ..color = (isDark ? const Color(0xFF331E12) : const Color(0xFFFFB300))
          .withValues(alpha: isDark ? 1 : 0.25);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.8, size.width, size.height * 0.2),
      groundPaint,
    );

    _drawReferenceAcacia(
      canvas,
      Offset(size.width * 0.28, size.height * 0.82),
      trunkPaint,
      foliagePaint,
    );
    _drawReferenceAcacia(
      canvas,
      Offset(size.width * 0.78, size.height * 0.78),
      trunkPaint,
      foliagePaint,
      scale: 0.65,
    );
  }

  void _drawReferenceAcacia(
    Canvas canvas,
    Offset base,
    Paint trunkPaint,
    Paint foliagePaint, {
    double scale = 1.0,
  }) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.scale(scale);

    final path = Path()
      ..moveTo(-12, 0)
      ..quadraticBezierTo(-18, -60, -10, -110)
      ..cubicTo(-25, -130, -60, -145, -85, -150)
      ..lineTo(-80, -162)
      ..cubicTo(-50, -155, -20, -140, -5, -130)
      ..cubicTo(15, -145, 45, -160, 75, -165)
      ..lineTo(80, -152)
      ..cubicTo(45, -142, 20, -130, 12, -110)
      ..quadraticBezierTo(18, -60, 12, 0)
      ..close();
    canvas.drawPath(path, trunkPaint);

    canvas.drawCircle(const Offset(-75, -155), 32, foliagePaint);
    canvas.drawCircle(const Offset(-45, -145), 28, foliagePaint);
    canvas.drawCircle(const Offset(65, -160), 38, foliagePaint);
    canvas.drawCircle(const Offset(25, -155), 32, foliagePaint);
    canvas.drawCircle(const Offset(95, -150), 25, foliagePaint);
    canvas.drawCircle(const Offset(0, -145), 35, foliagePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SavannaPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _ForestPainter extends CustomPainter {
  const _ForestPainter({required this.isDark, required this.twinkle});
  final bool isDark;
  final Animation<double> twinkle;

  @override
  void paint(Canvas canvas, Size size) {
    if (isDark) {
      _NightSkyPainter(twinkle: twinkle).paint(canvas, size);
    } else {
      _CloudPainter(
        const AppPalette(
          backgroundTop: Colors.transparent,
          background: Colors.transparent,
          backgroundBottom: Colors.transparent,
          primary: Colors.transparent,
          primaryDark: Colors.transparent,
          secondary: Colors.transparent,
          secondaryDark: Colors.transparent,
          playfulBlue: Colors.transparent,
          playfulMint: Colors.transparent,
          panel: Colors.transparent,
          panelBorder: Colors.transparent,
          cardBack: Colors.transparent,
          cardFront: Colors.transparent,
          mismatch: Colors.transparent,
          mismatchBackground: Colors.transparent,
          textDark: Colors.transparent,
          textMedium: Colors.transparent,
          textLight: Colors.transparent,
          lavender: Colors.transparent,
        ),
      ).paint(canvas, size);
    }

    final pinePaint = Paint()
      ..color = (isDark ? const Color(0xFF132E20) : const Color(0xFF1B5E20))
          .withValues(alpha: isDark ? 1 : 0.45);

    _drawDetailedPine(
      canvas,
      Offset(size.width * 0.12, size.height * 0.85),
      80,
      160,
      pinePaint,
    );
    _drawDetailedPine(
      canvas,
      Offset(size.width * 0.88, size.height * 0.85),
      80,
      160,
      pinePaint,
    );
  }

  void _drawDetailedPine(
    Canvas canvas,
    Offset base,
    double width,
    double height,
    Paint paint,
  ) {
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(base.dx, base.dy - 20),
        width: width * 0.15,
        height: 40,
      ),
      paint,
    );

    for (var i = 0; i < 4; i++) {
      final tierW = width * (1 - i * 0.18);
      final tierH = height * 0.3;
      final topY = base.dy - height + (i * height * 0.22);
      final path = Path()
        ..moveTo(base.dx, topY)
        ..lineTo(base.dx + tierW / 2, topY + tierH)
        ..lineTo(base.dx - tierW / 2, topY + tierH)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ForestPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

// ================================================================
// CIELO NOCTURNO: estrellitas + constelaciones suaves
// ================================================================

class _Constellation {
  const _Constellation({
    required this.color,
    required this.stars,
    required this.links,
  });

  final Color color;

  /// (x, y, tamaño) — x e y normalizados de 0 a 1.
  final List<(double, double, double)> stars;

  /// Pares de índices de `stars` que se unen con puntitos.
  final List<(int, int)> links;
}

class _NightSkyPainter extends CustomPainter {
  _NightSkyPainter({required this.twinkle}) : super(repaint: twinkle);

  final Animation<double> twinkle;

  // ---------- Constelaciones ----------

  static const _constellations = <_Constellation>[
    // Osa Mayor: mango curvo + cazo
    _Constellation(
      color: Color(0xFFFFE08A), // amarillo mantequilla
      stars: [
        (0.10, 0.20, 1.7), // 0 Alkaid
        (0.17, 0.165, 1.7), // 1 Mizar
        (0.24, 0.14, 1.7), // 2 Alioth
        (0.30, 0.16, 1.9), // 3 Megrez
        (0.33, 0.235, 1.9), // 4 Phecda
        (0.44, 0.245, 1.9), // 5 Merak
        (0.45, 0.17, 2.1), // 6 Dubhe
      ],
      links: [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 3)],
    ),

    // Osa Menor: mango con Polaris + cazo pequeñito
    _Constellation(
      color: Color(0xFF9EDBFF), // celeste
      stars: [
        (0.56, 0.28, 2.3), // 0 Polaris (la más brillante)
        (0.62, 0.31, 1.5), // 1 Yildun
        (0.67, 0.32, 1.5), // 2 Epsilon
        (0.71, 0.36, 1.6), // 3 Zeta
        (0.70, 0.42, 1.6), // 4 Eta
        (0.79, 0.44, 1.7), // 5 Gamma
        (0.80, 0.38, 1.9), // 6 Beta
      ],
      links: [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 3)],
    ),

    // Las Tres Marías: tres estrellas en fila, ligeramente inclinadas
    _Constellation(
      color: Color(0xFFFFB3D1), // rosa suave
      stars: [(0.14, 0.55, 2.1), (0.21, 0.575, 2.3), (0.28, 0.60, 2.1)],
      links: [(0, 1), (1, 2)],
    ),

    // Cruz del Sur: dos ejes que se cruzan + estrellita chica
    _Constellation(
      color: Color(0xFFA8F0D0), // menta
      stars: [
        (0.74, 0.68, 2.0), // 0 Gacrux (arriba)
        (0.755, 0.81, 2.3), // 1 Acrux (abajo)
        (0.68, 0.745, 2.0), // 2 Mimosa (izquierda)
        (0.81, 0.73, 1.8), // 3 Delta (derecha)
        (0.79, 0.775, 1.2), // 4 Epsilon (chiquita)
      ],
      links: [(0, 1), (2, 3)],
    ),
  ];

  // ---------- Estrellitas de fondo (fijas, siempre iguales) ----------

  // (x, y, radio, fase del titileo)
  static final List<(double, double, double, double)> _bgStars = () {
    final rnd = math.Random(42);
    return List.generate(
      46,
      (_) => (
        rnd.nextDouble(),
        rnd.nextDouble(),
        0.5 + rnd.nextDouble() * 0.7,
        rnd.nextDouble(),
      ),
    );
  }();

  @override
  void paint(Canvas canvas, Size size) {
    _paintMoon(canvas, size);

    // Estrellitas de fondo
    for (final (x, y, r, phase) in _bgStars) {
      final b = _brightness(phase);
      final c = Offset(size.width * x, size.height * y);
      canvas.drawCircle(
        c,
        r * 2.6,
        Paint()..color = Colors.white.withValues(alpha: 0.05 * b),
      );
      canvas.drawCircle(
        c,
        r,
        Paint()..color = Colors.white.withValues(alpha: 0.65 * b),
      );
    }

    // Constelaciones
    for (var ci = 0; ci < _constellations.length; ci++) {
      final group = _constellations[ci];
      final points = [
        for (final s in group.stars)
          Offset(size.width * s.$1, size.height * s.$2),
      ];

      // 1) Líneas de puntitos
      final dotPaint = Paint()..color = group.color.withValues(alpha: 0.38);
      for (final (a, b) in group.links) {
        _dottedLine(canvas, points[a], points[b], dotPaint);
      }

      // 2) Estrellas
      for (var i = 0; i < points.length; i++) {
        final size0 = group.stars[i].$3;
        final b = _brightness((ci * 0.23 + i * 0.13) % 1.0);
        _paintStar(canvas, points[i], size0, group.color, b);
      }
    }
  }

  /// Brillo entre 0.55 y 1.0, suave y cíclico.
  double _brightness(double phase) {
    final wave = math.sin(2 * math.pi * (twinkle.value + phase));
    return 0.775 + 0.225 * wave;
  }

  void _paintStar(
    Canvas canvas,
    Offset c,
    double r,
    Color color,
    double brightness,
  ) {
    // halo suave
    canvas.drawCircle(
      c,
      r * 4,
      Paint()..color = color.withValues(alpha: 0.13 * brightness),
    );
    canvas.drawCircle(
      c,
      r * 2.2,
      Paint()..color = color.withValues(alpha: 0.18 * brightness),
    );

    // brillito en cruz con puntas redondeadas
    final sparkle = Paint()
      ..color = Colors.white.withValues(alpha: 0.55 * brightness)
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;
    final arm = r * 2.6;
    canvas.drawLine(c.translate(-arm, 0), c.translate(arm, 0), sparkle);
    canvas.drawLine(c.translate(0, -arm), c.translate(0, arm), sparkle);

    // centro
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Color.lerp(
          Colors.white,
          color,
          0.35,
        )!.withValues(alpha: 0.95 * brightness),
    );
  }

  void _dottedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    final delta = b - a;
    final dist = delta.distance;
    if (dist < 16) return;

    final dir = delta / dist;
    // dejamos un espacio alrededor de cada estrella
    final start = a + dir * 7;
    final end = b - dir * 7;
    final length = (end - start).distance;
    final count = (length / 6).floor();

    for (var i = 0; i <= count; i++) {
      final p = Offset.lerp(start, end, count == 0 ? 0 : i / count)!;
      canvas.drawCircle(p, 0.9, paint);
    }
  }

  void _paintMoon(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.86, size.height * 0.09);
    const r = 17.0;
    const moonColor = Color(0xFFFFF4B3);

    canvas.drawCircle(
      center,
      r * 2.4,
      Paint()..color = moonColor.withValues(alpha: 0.08),
    );
    canvas.drawCircle(
      center,
      r * 1.6,
      Paint()..color = moonColor.withValues(alpha: 0.10),
    );

    final crescent = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: center, radius: r)),
      Path()..addOval(
        Rect.fromCircle(center: center.translate(7, -3), radius: r * 0.92),
      ),
    );
    canvas.drawPath(
      crescent,
      Paint()..color = moonColor.withValues(alpha: 0.95),
    );
  }

  @override
  bool shouldRepaint(covariant _NightSkyPainter oldDelegate) => false;
}

class _CloudPainter extends CustomPainter {
  const _CloudPainter(this.colors);

  final AppPalette colors;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.42);

    final clouds = <Offset>[
      Offset(size.width * 0.12, size.height * 0.16),
      Offset(size.width * 0.62, size.height * 0.12),
      Offset(size.width * 0.82, size.height * 0.22),
      Offset(size.width * 0.28, size.height * 0.34),
    ];

    for (final center in clouds) {
      final cloudRadius = size.width * 0.09;
      canvas.drawCircle(center, cloudRadius, paint);
      canvas.drawCircle(
        Offset(center.dx + cloudRadius * 0.8, center.dy),
        cloudRadius * 0.9,
        paint,
      );
      canvas.drawCircle(
        Offset(center.dx - cloudRadius * 0.8, center.dy),
        cloudRadius * 0.85,
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + cloudRadius * 0.2),
            width: cloudRadius * 3.2,
            height: cloudRadius * 1.8,
          ),
          Radius.circular(cloudRadius),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) => false;
}

// ================================================================
// PANEL DE COLOR
// ================================================================

class PlayfulPanel extends StatelessWidget {
  const PlayfulPanel({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 22,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.panel, colors.panel.withValues(alpha: 0.94)],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: colors.panelBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: colors.textDark.withValues(alpha: 0.1),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.55),
            blurRadius: 0,
            spreadRadius: 0,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ================================================================
// CONFETI
// ================================================================

class _PlayfulConfettiPainter extends CustomPainter {
  const _PlayfulConfettiPainter(this.colors);

  final AppPalette colors;

  @override
  void paint(Canvas canvas, Size size) {
    const points = <(double, double, double)>[
      (0.08, 0.14, 3.0),
      (0.23, 0.26, 2.0),
      (0.39, 0.10, 2.5),
      (0.56, 0.22, 2.0),
      (0.74, 0.12, 3.0),
      (0.91, 0.28, 2.0),
      (0.13, 0.49, 2.0),
      (0.31, 0.60, 3.0),
      (0.48, 0.43, 2.0),
      (0.66, 0.55, 2.5),
      (0.84, 0.46, 2.0),
      (0.07, 0.82, 2.5),
      (0.26, 0.91, 2.0),
      (0.47, 0.77, 3.0),
      (0.69, 0.91, 2.0),
      (0.91, 0.78, 2.5),
    ];
    for (final (x, y, r) in points) {
      final paint = Paint()..color = colors.secondary.withValues(alpha: 0.25);
      canvas.drawCircle(Offset(size.width * x, size.height * y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PlayfulConfettiPainter oldDelegate) => false;
}
