import 'package:flutter/material.dart';
import 'package:uzme/core/models/app_user.dart';
import 'package:uzme/core/models/card_config.dart';
import 'package:uzme/core/services/card_export_service.dart';
import 'package:uzme/widgets/card/holo_card_content.dart';
import 'package:uzme/widgets/card/holo_card_theme.dart';

/// Export-only background — intentionally hardcoded because this renders
/// to a standalone PNG, not an in-app UI surface.
const Color _kExportBg = Color(0xFF0A0E21);

/// Social media export template that wraps the real [HoloCardContent]
/// in a branded background sized for the target [format].
///
/// Uses [FittedBox] so the card scales proportionally in every format
/// without any overflow — same rendering as [DigitalCardSheet].
class CardExportTemplate extends StatelessWidget {
  final AppUser user;
  final CardConfig cardConfig;
  final CardExportFormat format;

  const CardExportTemplate({
    super.key,
    required this.user,
    required this.cardConfig,
    required this.format,
  });

  HoloCardTheme get _theme {
    if (!cardConfig.isDefault) {
      return HoloCardTheme.fromConfig(
        config: cardConfig,
        role: user.role,
        isPioneer: user.isPioneer,
      );
    }
    return HoloCardTheme.forRole(user.role, isPioneer: user.isPioneer);
  }

  String get _displayName {
    final isStudio = user.isStudio || user.isSuperAdmin;
    return isStudio
        ? user.studioDisplayName
        : (user.stageName ?? user.displayName ?? user.name ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = _theme;
    final isLandscape = format == CardExportFormat.landscape;

    return AspectRatio(
      aspectRatio: format.aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _kExportBg,
              theme.primaryColor.withValues(alpha: 0.4),
              _kExportBg,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Radial glow
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.glowColor.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLandscape ? 40 : 28,
                vertical: isLandscape ? 20 : 24,
              ),
              child: isLandscape
                  ? _buildLandscape(theme)
                  : _buildVertical(theme),
            ),
          ],
        ),
      ),
    );
  }

  /// Story / Post — card centered vertically with footer below.
  Widget _buildVertical(HoloCardTheme theme) {
    return Column(
      children: [
        const Spacer(flex: 2),
        Flexible(
          flex: 7,
          child: Center(child: _cardWidget(theme)),
        ),
        const Spacer(),
        _footer(theme),
        const SizedBox(height: 8),
        _watermark(theme),
        const Spacer(),
      ],
    );
  }

  /// Landscape — card left, info right.
  Widget _buildLandscape(HoloCardTheme theme) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Center(child: _cardWidget(theme)),
        ),
        const SizedBox(width: 28),
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _footer(theme),
              const SizedBox(height: 12),
              _watermark(theme),
            ],
          ),
        ),
      ],
    );
  }

  /// The actual card — reuses [HoloCardContent] inside a scaled container.
  /// Everything (decoration, radius, content) is inside [FittedBox] so
  /// border radius and content scale proportionally together.
  Widget _cardWidget(HoloCardTheme theme) {
    const refW = 340.0;
    const refH = refW / 1.586;

    return AspectRatio(
      aspectRatio: 1.586,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: refW,
          height: refH,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor.withValues(alpha: 0.5),
                  theme.secondaryColor.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.glowColor.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: HoloCardContent(user: user, theme: theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _footer(HoloCardTheme theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _displayName,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          'uzme.app/u/${user.uid.substring(0, 8)}',
          style: TextStyle(
            fontSize: 11,
            color: theme.accentColor.withValues(alpha: 0.7),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _watermark(HoloCardTheme theme) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          theme.accentColor.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.3),
        ],
      ).createShader(bounds),
      child: const Text(
        'UZME',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 4,
        ),
      ),
    );
  }
}
