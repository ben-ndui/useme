import 'package:flutter/material.dart';

/// Glass-morphism color scheme for dashboard feeds on dark gradient backgrounds.
/// Converts a standard ColorScheme into translucent white-based glass colors.
ColorScheme glassColorScheme(ColorScheme base) {
  return base.copyWith(
    surface: Colors.transparent,
    surfaceContainerLow: Colors.white.withValues(alpha: 0.04),
    surfaceContainer: Colors.white.withValues(alpha: 0.06),
    surfaceContainerHigh: Colors.white.withValues(alpha: 0.08),
    surfaceContainerHighest: Colors.white.withValues(alpha: 0.10),
    onSurface: Colors.white,
    onSurfaceVariant: Colors.white.withValues(alpha: 0.7),
    outline: Colors.white.withValues(alpha: 0.5),
    outlineVariant: Colors.white.withValues(alpha: 0.15),
    primaryContainer: base.primary.withValues(alpha: 0.20),
    onPrimaryContainer: Colors.white,
  );
}
