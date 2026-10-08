import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_durations.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/memory_card.dart';

class AnimalMemoryGame extends FlameGame with TapCallbacks {
  factory AnimalMemoryGame({
    required List<MemoryCard> cards,
    required int? starCardId,
    required AppPalette colors,
    required bool isDark,
    required ValueChanged<int> onCardTap,
  }) {
    return AnimalMemoryGame._(
      cards: cards,
      starCardId: starCardId,
      colors: colors,
      isDark: isDark,
      onCardTap: onCardTap,
    );
  }

  AnimalMemoryGame._({
    required List<MemoryCard> cards,
    required this._starCardId,
    required this._colors,
    required this._isDark,
    required this._onCardTap,
  }) {
    updateCards(cards);
  }

  static const double _spacing = 6;

  final Map<int, _CardVisual> _cardVisuals = {};
  final List<int> _cardOrder = [];
  int? _starCardId;
  AppPalette _colors;
  bool _isDark;
  ValueChanged<int> _onCardTap;
  int _columns = 3;
  int _rows = 0;
  double _cellWidth = 0;
  double _cellHeight = 0;
  bool _hasLayout = false;

  @override
  Color backgroundColor() => Colors.transparent;

  void updateBoard({
    required List<MemoryCard> cards,
    required int? starCardId,
    required AppPalette colors,
    required bool isDark,
    required ValueChanged<int> onCardTap,
  }) {
    _starCardId = starCardId;
    _colors = colors;
    _isDark = isDark;
    _onCardTap = onCardTap;
    updateCards(cards);
  }

  void updateCards(List<MemoryCard> cards) {
    final ids = cards.map((card) => card.id).toSet();
    _cardVisuals.removeWhere((id, _) => !ids.contains(id));
    _cardOrder
      ..clear()
      ..addAll(cards.map((card) => card.id));

    for (final card in cards) {
      final visual = _cardVisuals[card.id];
      if (visual == null) {
        _cardVisuals[card.id] = _CardVisual(card);
      } else {
        visual.updateCard(card);
      }
    }
    _layoutCards();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _hasLayout = true;
    _layoutCards();
  }

  void _layoutCards() {
    if (!_hasLayout || size.x <= 0 || size.y <= 0) return;
    if (_cardOrder.isEmpty) return;

    _columns = size.x > size.y ? 4 : 3;
    _rows = (_cardOrder.length / _columns).ceil();
    _cellWidth = (size.x - _spacing * (_columns - 1)) / _columns;
    _cellHeight = (size.y - _spacing * (_rows - 1)) / _rows;
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final visual in _cardVisuals.values) {
      visual.update(dt);
    }
  }

  @override
  void render(ui.Canvas canvas) {
    super.render(canvas);
    if (_rows == 0) return;

    var index = 0;
    for (final id in _cardOrder) {
      final visual = _cardVisuals[id]!;
      final column = index % _columns;
      final row = index ~/ _columns;
      final rect = Rect.fromLTWH(
        column * (_cellWidth + _spacing),
        row * (_cellHeight + _spacing),
        _cellWidth,
        _cellHeight,
      );
      _renderCard(canvas, rect, visual);
      index++;
    }
  }

  void _renderCard(ui.Canvas canvas, Rect rect, _CardVisual visual) {
    if (visual.opacity <= 0.001) return;
    final angle = visual.faceProgress * math.pi;
    final widthScale = math.cos(angle).abs().clamp(0.001, 1.0);
    final showFront = visual.faceProgress >= 0.5;
    final cardRect = Rect.fromCenter(
      center: rect.center,
      width: rect.width * widthScale,
      height: rect.height,
    );
    final rrect = RRect.fromRectAndRadius(
      cardRect,
      Radius.circular(math.min(22, cardRect.shortestSide * 0.12)),
    );

    canvas.drawRRect(
      rrect.shift(const Offset(0, 6)),
      ui.Paint()
        ..color = Colors.black.withValues(alpha: 0.14 * visual.opacity)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 7),
    );

    if (showFront) {
      _renderFront(canvas, rrect, visual);
    } else {
      _renderBack(canvas, rrect, visual.card.id == _starCardId, visual.opacity);
    }
  }

  void _renderBack(
    ui.Canvas canvas,
    RRect rrect,
    bool isStarred,
    double opacity,
  ) {
    final rect = rrect.outerRect;
    final gradient = ui.Gradient.linear(rect.topLeft, rect.bottomRight, [
      _colors.cardBack.withValues(alpha: opacity),
      _colors.playfulBlue.withValues(alpha: 0.82 * opacity),
    ]);
    canvas.drawRRect(rrect, ui.Paint()..shader = gradient);
    canvas.drawRRect(
      rrect,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.75 * opacity),
    );
    _drawMaterialIcon(
      canvas,
      Icons.pets_rounded,
      rect.center,
      38,
      opacity: opacity,
    );
    if (isStarred) {
      _drawMaterialIcon(
        canvas,
        Icons.star_rounded,
        Offset(rect.right - 23, rect.top + 21),
        26,
        color: Colors.amber,
        opacity: opacity,
      );
    }
  }

  void _drawMaterialIcon(
    ui.Canvas canvas,
    IconData icon,
    Offset center,
    double size, {
    Color color = Colors.white,
    double opacity = 1,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: color.withValues(alpha: color.a * opacity),
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: size,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  void _renderFront(ui.Canvas canvas, RRect rrect, _CardVisual visual) {
    final rect = rrect.outerRect;
    final darkPairColors = const [
      Color(0xFF34496B),
      Color(0xFF4B385E),
      Color(0xFF31584F),
      Color(0xFF624652),
      Color(0xFF665334),
      Color(0xFF38566B),
    ];
    final lightPairColors = [
      _colors.cardFront,
      const Color(0xFFBDEBFF),
      const Color(0xFFFFC9D5),
      const Color(0xFFC6F0C7),
      const Color(0xFFE1D5FF),
      const Color(0xFFFFD4A6),
    ];
    final pairColor = (_isDark
        ? darkPairColors
        : lightPairColors)[visual.card.pairId % 6];
    final faceColor = Color.lerp(
      pairColor,
      _colors.mismatchBackground,
      visual.mismatchProgress,
    )!;
    final borderColor = Color.lerp(
      _colors.textDark.withValues(alpha: 0.18),
      _colors.mismatch,
      visual.mismatchProgress,
    )!;
    final rectGradient = ui.Gradient.linear(rect.topLeft, rect.bottomRight, [
      faceColor.withValues(alpha: faceColor.a * visual.opacity),
      faceColor.withValues(alpha: 0.82 * visual.opacity),
    ]);
    canvas.drawRRect(rrect, ui.Paint()..shader = rectGradient);
    canvas.drawRRect(
      rrect,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = visual.mismatchProgress > 0.5 ? 2.5 : 2
        ..color = borderColor.withValues(alpha: borderColor.a * visual.opacity),
    );

    final padding = math.min(8.0, rect.shortestSide * 0.07);
    final contentRect = rect.deflate(padding);
    final emojiArea = Rect.fromLTRB(
      contentRect.left,
      contentRect.top,
      contentRect.right,
      contentRect.bottom - 18,
    );
    _drawCenteredText(
      canvas,
      visual.card.symbol,
      emojiArea,
      fontSize: math.min(58, emojiArea.height),
      opacity: visual.opacity,
    );
    final labelColor = _isDark ? Colors.white : const Color(0xFF33415C);
    _drawCenteredText(
      canvas,
      visual.card.animalName,
      Rect.fromLTWH(
        contentRect.left,
        contentRect.bottom - 16,
        contentRect.width,
        16,
      ),
      fontSize: 11,
      fontWeight: FontWeight.w800,
      color: labelColor,
      maxLines: 1,
      opacity: visual.opacity,
    );
  }

  void _drawCenteredText(
    ui.Canvas canvas,
    String text,
    Rect bounds, {
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
    int? maxLines,
    double opacity = 1,
  }) {
    var size = fontSize;
    late TextPainter painter;
    do {
      painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color.withValues(alpha: color.a * opacity),
            fontSize: size,
            fontWeight: fontWeight,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: maxLines,
        ellipsis: maxLines == null ? null : '…',
      )..layout(maxWidth: bounds.width);
      if ((painter.width <= bounds.width && painter.height <= bounds.height) ||
          size <= 8) {
        break;
      }
      size *= 0.9;
    } while (true);

    painter.paint(
      canvas,
      Offset(
        bounds.center.dx - painter.width / 2,
        bounds.center.dy - painter.height / 2,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (_rows == 0 || _cellWidth <= 0 || _cellHeight <= 0) return;

    final point = event.localPosition;
    final column = (point.x / (_cellWidth + _spacing)).floor();
    final row = (point.y / (_cellHeight + _spacing)).floor();
    if (column < 0 || column >= _columns || row < 0 || row >= _rows) return;

    final localX = point.x - column * (_cellWidth + _spacing);
    final localY = point.y - row * (_cellHeight + _spacing);
    if (localX > _cellWidth || localY > _cellHeight) return;

    final index = row * _columns + column;
    if (index >= _cardOrder.length) return;
    _onCardTap(_cardOrder[index]);
  }
}

class _CardVisual {
  _CardVisual(this.card)
    : faceTarget = card.isFaceUp ? 1 : 0,
      opacityTarget = card.isMatched ? 0 : 1,
      hasMatched = card.isMatched,
      mismatchTarget = card.status == CardStatus.mismatched ? 1 : 0;

  MemoryCard card;
  bool hasMatched;
  double faceProgress = 0;
  double faceStart = 0;
  double faceTarget;
  double faceElapsed = 0;
  double opacity = 1;
  double opacityStart = 1;
  double opacityTarget;
  double opacityElapsed = 0;
  double mismatchProgress = 0;
  double mismatchStart = 0;
  double mismatchTarget;
  double mismatchElapsed = 0;

  void updateCard(MemoryCard nextCard) {
    card = nextCard;
    animateFace(nextCard.isFaceUp ? 1 : 0);
    if (nextCard.isMatched != hasMatched) {
      hasMatched = nextCard.isMatched;
      animateOpacity(hasMatched ? 0 : 1);
    }
    animateMismatch(nextCard.status == CardStatus.mismatched ? 1 : 0);
  }

  void animateFace(double target) {
    if (target == faceTarget) return;
    faceStart = faceProgress;
    faceTarget = target;
    faceElapsed = 0;
  }

  void animateOpacity(double target) {
    if (target == opacityTarget) return;
    opacityStart = opacity;
    opacityTarget = target;
    opacityElapsed = 0;
  }

  void animateMismatch(double target) {
    if (target == mismatchTarget) return;
    mismatchStart = mismatchProgress;
    mismatchTarget = target;
    mismatchElapsed = 0;
  }

  void update(double dt) {
    faceProgress = _interpolate(
      faceStart,
      faceTarget,
      faceElapsed,
      dt,
      AppDurations.cardFlip,
      (elapsed) => faceElapsed = elapsed,
    );
    opacity = _interpolate(
      opacityStart,
      opacityTarget,
      opacityElapsed,
      dt,
      AppDurations.cardDisappear,
      (elapsed) => opacityElapsed = elapsed,
    );
    mismatchProgress = _interpolate(
      mismatchStart,
      mismatchTarget,
      mismatchElapsed,
      dt,
      AppDurations.cardColor,
      (elapsed) => mismatchElapsed = elapsed,
    );
  }

  double _interpolate(
    double start,
    double target,
    double elapsed,
    double dt,
    Duration duration,
    ValueChanged<double> setElapsed,
  ) {
    if (start == target) return target;
    final durationSeconds =
        duration.inMicroseconds / Duration.microsecondsPerSecond;
    final nextElapsed = (elapsed + dt).clamp(0.0, durationSeconds).toDouble();
    setElapsed(nextElapsed);
    final progress = Curves.easeInOut.transform(nextElapsed / durationSeconds);
    return ui.lerpDouble(start, target, progress)!;
  }
}
