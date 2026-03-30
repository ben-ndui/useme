import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/widgets/card/gyroscope_controller.dart';
import 'package:useme/widgets/card/holo_card_content.dart';
import 'package:useme/widgets/card/holo_card_theme.dart';
import 'package:useme/widgets/card/holo_gradient_overlay.dart';

/// Premium holographic digital business card with 3D gyroscope tilt.
/// Combines a glassmorphism base, holographic rainbow overlay,
/// and perspective transform driven by device orientation.
class HoloCard extends StatefulWidget {
  final AppUser user;

  const HoloCard({super.key, required this.user});

  @override
  State<HoloCard> createState() => _HoloCardState();
}

class _HoloCardState extends State<HoloCard> {
  final _gyro = GyroscopeController();
  // Fallback drag tilt for simulator/desktop
  Offset _dragTilt = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _gyro.init();
  }

  @override
  void dispose() {
    _gyro.dispose();
    super.dispose();
  }

  HoloCardTheme get _theme => HoloCardTheme.forRole(
        widget.user.role,
        isPioneer: widget.user.isPioneer,
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (_) => _isDragging = true,
      onPanUpdate: (details) {
        setState(() {
          _dragTilt = Offset(
            (_dragTilt.dx + details.delta.dx * 0.005).clamp(-1.0, 1.0),
            (_dragTilt.dy + details.delta.dy * 0.005).clamp(-1.0, 1.0),
          );
        });
      },
      onPanEnd: (_) {
        _isDragging = false;
        // Animate back to center
        setState(() => _dragTilt = Offset.zero);
      },
      child: ValueListenableBuilder<Offset>(
        valueListenable: _gyro.tilt,
        builder: (context, gyroTilt, _) {
          // Use drag tilt when dragging, gyroscope otherwise
          final tilt = _isDragging ? _dragTilt : gyroTilt;
          return _buildCard(tilt);
        },
      ),
    );
  }

  Widget _buildCard(Offset tilt) {
    final theme = _theme;

    // 3D perspective transform — amplified for visible effect
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.0015)
      ..rotateX(tilt.dy * 0.35)
      ..rotateY(-tilt.dx * 0.35);

    // Dynamic shadow follows opposite of tilt
    final shadowOffset = Offset(-tilt.dx * 25, -tilt.dy * 25);

    return AnimatedContainer(
      duration: _isDragging
          ? Duration.zero
          : const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Transform(
        transform: transform,
        alignment: FractionalOffset.center,
        child: AspectRatio(
          aspectRatio: 1.586,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.glowColor.withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: shadowOffset,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: shadowOffset * 0.5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.primaryColor.withValues(alpha: 0.4),
                        theme.secondaryColor.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      HoloCardContent(user: widget.user, theme: theme),
                      HoloGradientOverlay(tilt: tilt, theme: theme),
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
