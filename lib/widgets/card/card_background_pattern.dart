import 'dart:math';

import 'package:flutter/material.dart';
import 'package:useme/core/models/card_config.dart';
import 'package:useme/widgets/card/holo_card_theme.dart';

/// Renders a subtle background pattern overlay on the card.
class CardBackgroundPatternWidget extends StatelessWidget {
  final CardBackgroundPattern pattern;
  final HoloCardTheme theme;

  const CardBackgroundPatternWidget({
    super.key,
    required this.pattern,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _PatternPainter(pattern: pattern, theme: theme),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final CardBackgroundPattern pattern;
  final HoloCardTheme theme;

  _PatternPainter({required this.pattern, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    switch (pattern) {
      case CardBackgroundPattern.gradient:
        _paintGradient(canvas, size);
      case CardBackgroundPattern.waves:
        _paintWaves(canvas, size);
      case CardBackgroundPattern.dots:
        _paintDots(canvas, size);
      case CardBackgroundPattern.none:
        break;
    }
  }

  void _paintGradient(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          theme.accentColor.withValues(alpha: 0.15),
          theme.primaryColor.withValues(alpha: 0.05),
          theme.secondaryColor.withValues(alpha: 0.12),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _paintWaves(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = theme.accentColor.withValues(alpha: 0.12);

    for (var i = 0; i < 5; i++) {
      final path = Path();
      final yOffset = size.height * 0.2 + (i * size.height * 0.15);
      path.moveTo(0, yOffset);

      for (var x = 0.0; x < size.width; x += 1) {
        final y = yOffset + sin((x / size.width) * pi * 3 + i * 0.8) * 12;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  void _paintDots(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = theme.accentColor.withValues(alpha: 0.1);

    const spacing = 20.0;
    const radius = 1.5;

    for (var x = spacing; x < size.width; x += spacing) {
      for (var y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_PatternPainter oldDelegate) =>
      pattern != oldDelegate.pattern || theme != oldDelegate.theme;
}
