import 'dart:math';

import 'package:flutter/material.dart';
import 'package:useme/widgets/card/holo_card_theme.dart';

/// Animated holographic rainbow gradient + specular highlight overlay.
/// Reacts to [tilt] offset to create a shifting holographic shimmer.
class HoloGradientOverlay extends StatelessWidget {
  final Offset tilt;
  final HoloCardTheme theme;

  const HoloGradientOverlay({
    super.key,
    required this.tilt,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final tiltMagnitude = tilt.distance.clamp(0.0, 1.0);
    // More tilt = more visible holographic effect
    final holoOpacity = 0.08 + (tiltMagnitude * 0.18);
    final specularOpacity = 0.05 + (tiltMagnitude * 0.25);

    // Rotation angle derived from tilt direction
    final angle = tilt.dx * pi * 0.5 + tilt.dy * pi * 0.3;

    return IgnorePointer(
      child: Stack(
        children: [
          // Rainbow sweep gradient
          Positioned.fill(
            child: Opacity(
              opacity: holoOpacity,
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return SweepGradient(
                    center: Alignment(
                      (tilt.dx * 0.3).clamp(-0.5, 0.5),
                      (tilt.dy * 0.3).clamp(-0.5, 0.5),
                    ),
                    colors: HoloCardTheme.holoRainbow,
                    transform: GradientRotation(angle),
                  ).createShader(bounds);
                },
                blendMode: BlendMode.overlay,
                child: Container(color: Colors.white),
              ),
            ),
          ),

          // Specular highlight (light reflection)
          Positioned.fill(
            child: Opacity(
              opacity: specularOpacity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      (tilt.dx * 1.5).clamp(-1.0, 1.0),
                      (tilt.dy * 1.5).clamp(-1.0, 1.0),
                    ),
                    radius: 0.8,
                    colors: [
                      Colors.white.withValues(alpha: 0.6),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Subtle edge glow in theme color
          Positioned.fill(
            child: Opacity(
              opacity: 0.1 + (tiltMagnitude * 0.1),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      (-tilt.dx).clamp(-1.0, 1.0),
                      (-tilt.dy).clamp(-1.0, 1.0),
                    ),
                    end: Alignment(
                      tilt.dx.clamp(-1.0, 1.0),
                      tilt.dy.clamp(-1.0, 1.0),
                    ),
                    colors: [
                      theme.primaryColor.withValues(alpha: 0.3),
                      theme.secondaryColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
