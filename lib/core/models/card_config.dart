import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Theme presets for the digital card.
enum CardThemePreset {
  // --- Free ---
  /// Default role-based theme (blue/cyan/purple).
  defaultRole,

  /// Dark theme — deep black/charcoal.
  dark,

  /// Light theme — clean white/silver.
  light,

  /// Neon theme — vibrant electric colors.
  neon,

  /// Minimal theme — subtle muted tones.
  minimal,

  // --- Premium ---
  /// Holographic Pro — iridescent shifting colors.
  holographicPro,

  /// Carbon — dark carbon fiber texture feel.
  carbon,

  /// Gold — luxury gold & black.
  gold,

  /// Galaxy — deep space nebula colors.
  galaxy,
}

/// Whether a [CardThemePreset] requires a paid subscription or Pioneer status.
extension CardThemePresetPremium on CardThemePreset {
  bool get isPremium => switch (this) {
        CardThemePreset.holographicPro ||
        CardThemePreset.carbon ||
        CardThemePreset.gold ||
        CardThemePreset.galaxy =>
          true,
        _ => false,
      };
}

/// Background pattern overlays for the card.
enum CardBackgroundPattern {
  none,
  gradient,
  waves,
  dots,
}

/// Persistent card customization stored in Firestore.
class CardConfig extends Equatable {
  final CardThemePreset preset;
  final int? accentColorValue;
  final CardBackgroundPattern backgroundPattern;

  /// Custom background image URL (Firebase Storage). Premium only.
  final String? backgroundImageUrl;

  const CardConfig({
    this.preset = CardThemePreset.defaultRole,
    this.accentColorValue,
    this.backgroundPattern = CardBackgroundPattern.none,
    this.backgroundImageUrl,
  });

  /// The accent color as a Flutter Color, or null for default.
  Color? get accentColor =>
      accentColorValue != null ? Color(accentColorValue!) : null;

  /// Whether this config uses any premium feature.
  bool get usesPremium =>
      preset.isPremium || backgroundImageUrl != null;

  /// Whether this is the default config (no customization).
  bool get isDefault =>
      preset == CardThemePreset.defaultRole &&
      accentColorValue == null &&
      backgroundPattern == CardBackgroundPattern.none &&
      backgroundImageUrl == null;

  factory CardConfig.fromMap(Map<String, dynamic> map) {
    return CardConfig(
      preset: CardThemePreset.values.firstWhere(
        (e) => e.name == map['preset'],
        orElse: () => CardThemePreset.defaultRole,
      ),
      accentColorValue: map['accentColorValue'] as int?,
      backgroundPattern: CardBackgroundPattern.values.firstWhere(
        (e) => e.name == map['backgroundPattern'],
        orElse: () => CardBackgroundPattern.none,
      ),
      backgroundImageUrl: map['backgroundImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'preset': preset.name,
      if (accentColorValue != null) 'accentColorValue': accentColorValue,
      'backgroundPattern': backgroundPattern.name,
      if (backgroundImageUrl != null) 'backgroundImageUrl': backgroundImageUrl,
    };
  }

  CardConfig copyWith({
    CardThemePreset? preset,
    int? accentColorValue,
    CardBackgroundPattern? backgroundPattern,
    String? backgroundImageUrl,
    bool clearAccentColor = false,
    bool clearBackgroundImage = false,
  }) {
    return CardConfig(
      preset: preset ?? this.preset,
      accentColorValue:
          clearAccentColor ? null : (accentColorValue ?? this.accentColorValue),
      backgroundPattern: backgroundPattern ?? this.backgroundPattern,
      backgroundImageUrl: clearBackgroundImage
          ? null
          : (backgroundImageUrl ?? this.backgroundImageUrl),
    );
  }

  @override
  List<Object?> get props =>
      [preset, accentColorValue, backgroundPattern, backgroundImageUrl];
}
