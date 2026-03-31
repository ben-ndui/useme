import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/card_config/card_config_exports.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/card_config.dart';
import 'package:useme/core/services/card_background_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/card/holo_card.dart';
import 'package:useme/widgets/card/holo_card_theme.dart';

/// Screen for customizing the digital card appearance.
class CardCustomizationScreen extends StatefulWidget {
  const CardCustomizationScreen({super.key});

  @override
  State<CardCustomizationScreen> createState() =>
      _CardCustomizationScreenState();
}

class _CardCustomizationScreenState extends State<CardCustomizationScreen> {
  late CardConfig _draft;
  bool _initialized = false;
  bool _isUploadingBg = false;
  final _bgService = CardBackgroundService();

  /// Whether the user can access premium features.
  bool _canAccessPremium(AppUser user) =>
      user.hasPaidSubscription || user.isPioneer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticatedState) {
          return const SizedBox.shrink();
        }
        final user = authState.user as AppUser;
        final isPremium = _canAccessPremium(user);

        return BlocConsumer<CardConfigBloc, CardConfigState>(
          listener: (context, state) {
            if (!_initialized && state.isLoaded) {
              setState(() {
                _draft = state.config;
                _initialized = true;
              });
            }
            if (state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.cardSaved)),
              );
              Navigator.pop(context);
            }
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            if (!_initialized) {
              _draft = state.config;
              _initialized = true;
            }

            return Scaffold(
              backgroundColor: cs.surface,
              appBar: _buildAppBar(context, user, state, l10n, cs),
              body: _buildBody(context, user, isPremium, l10n, cs),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppUser user,
    CardConfigState state,
    AppLocalizations l10n,
    ColorScheme cs,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(l10n.customizeCard,
          style: TextStyle(color: cs.onSurface)),
      iconTheme: IconThemeData(color: cs.onSurface),
      actions: [
        if (!_draft.isDefault)
          IconButton(
            icon: FaIcon(FontAwesomeIcons.arrowRotateLeft,
                size: 18, color: cs.onSurfaceVariant),
            onPressed: () => setState(() => _draft = const CardConfig()),
            tooltip: l10n.reset,
          ),
        IconButton(
          icon: state.isSaving
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.onSurface,
                  ),
                )
              : FaIcon(FontAwesomeIcons.check,
                  size: 18, color: cs.onSurface),
          onPressed: state.isSaving
              ? null
              : () => context.read<CardConfigBloc>().add(
                    SaveCardConfigEvent(userId: user.uid, config: _draft),
                  ),
          tooltip: l10n.save,
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppUser user,
    bool isPremium,
    AppLocalizations l10n,
    ColorScheme cs,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live preview
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: HoloCard(user: user, cardConfig: _draft),
            ),
          ),
          const SizedBox(height: 28),

          // Theme preset selector
          _SectionTitle(title: l10n.cardTheme),
          const SizedBox(height: 12),
          _buildPresetGrid(cs, isPremium, l10n),
          const SizedBox(height: 24),

          // Accent color palette
          _SectionTitle(title: l10n.cardAccentColor),
          const SizedBox(height: 12),
          _buildColorPalette(cs),
          const SizedBox(height: 24),

          // Background pattern
          _SectionTitle(title: l10n.cardPattern),
          const SizedBox(height: 12),
          _buildPatternSelector(l10n, cs),
          const SizedBox(height: 24),

          // Background image (premium)
          _buildBackgroundImageSection(user, isPremium, l10n, cs),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Preset Grid ──

  Widget _buildPresetGrid(
      ColorScheme cs, bool isPremium, AppLocalizations l10n) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: CardThemePreset.values.map((preset) {
        final isSelected = _draft.preset == preset;
        final isLocked = preset.isPremium && !isPremium;
        final colors = HoloCardTheme.presetPreviewColors(preset);

        return GestureDetector(
          onTap: () {
            if (isLocked) {
              _showUpgradeSnackbar(l10n);
              return;
            }
            setState(() => _draft = _draft.copyWith(preset: preset));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? cs.onSurface : cs.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colors.last.withValues(alpha: 0.4),
                        blurRadius: 12,
                      )
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    _presetLabel(preset),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: preset == CardThemePreset.light
                          ? Colors.black87
                          : Colors.white,
                    ),
                  ),
                ),
                if (isLocked)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: FaIcon(
                      FontAwesomeIcons.lock,
                      size: 10,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Color Palette ──

  Widget _buildColorPalette(ColorScheme cs) {
    const colors = [
      null,
      Color(0xFFE94560),
      Color(0xFFFF6B6B),
      Color(0xFFFF9F43),
      Color(0xFFFFD700),
      Color(0xFF00FF87),
      Color(0xFF00CEC9),
      Color(0xFF74B9FF),
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFFA78BFA),
      Color(0xFFFF6FF6),
      Color(0xFFBDC3C7),
      Color(0xFFFFFFFF),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors.map((color) {
        final isSelected = color?.toARGB32() == _draft.accentColorValue ||
            (color == null && _draft.accentColorValue == null);

        return GestureDetector(
          onTap: () => setState(() {
            _draft = color != null
                ? _draft.copyWith(accentColorValue: color.toARGB32())
                : _draft.copyWith(clearAccentColor: true);
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color ?? cs.surfaceContainerHigh,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? cs.onSurface : cs.outlineVariant,
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected && color != null
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 10,
                      )
                    ]
                  : null,
            ),
            child: color == null
                ? Center(
                    child: FaIcon(
                      FontAwesomeIcons.dropletSlash,
                      size: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  // ── Pattern Selector ──

  Widget _buildPatternSelector(AppLocalizations l10n, ColorScheme cs) {
    final patterns = [
      (CardBackgroundPattern.none, FontAwesomeIcons.ban, l10n.patternNone),
      (CardBackgroundPattern.gradient, FontAwesomeIcons.palette,
          l10n.patternGradient),
      (CardBackgroundPattern.waves, FontAwesomeIcons.water,
          l10n.patternWaves),
      (CardBackgroundPattern.dots, FontAwesomeIcons.braille,
          l10n.patternDots),
    ];

    return Row(
      children: patterns.map((item) {
        final (pattern, icon, label) = item;
        final isSelected = _draft.backgroundPattern == pattern;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(
              () => _draft = _draft.copyWith(backgroundPattern: pattern),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? cs.surfaceContainerHighest
                    : cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? cs.outline : cs.outlineVariant,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  FaIcon(icon,
                      size: 18,
                      color: isSelected
                          ? cs.onSurface
                          : cs.onSurfaceVariant),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? cs.onSurface
                          : cs.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Background Image (Premium) ──

  Widget _buildBackgroundImageSection(
    AppUser user,
    bool isPremium,
    AppLocalizations l10n,
    ColorScheme cs,
  ) {
    final hasImage = _draft.backgroundImageUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SectionTitle(title: l10n.cardBackgroundImage),
            const SizedBox(width: 8),
            if (!isPremium)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Pick image button
            GestureDetector(
              onTap: isPremium ? () => _pickBackgroundImage(user) : () => _showUpgradeSnackbar(l10n),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outlineVariant),
                  image: hasImage
                      ? DecorationImage(
                          image: NetworkImage(_draft.backgroundImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _isUploadingBg
                    ? Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.onSurface,
                          ),
                        ),
                      )
                    : !hasImage
                        ? Center(
                            child: FaIcon(
                              isPremium
                                  ? FontAwesomeIcons.image
                                  : FontAwesomeIcons.lock,
                              size: 20,
                              color: cs.onSurfaceVariant,
                            ),
                          )
                        : null,
              ),
            ),
            if (hasImage) ...[
              const SizedBox(width: 12),
              // Remove image button
              GestureDetector(
                onTap: () => setState(
                    () => _draft = _draft.copyWith(clearBackgroundImage: true)),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.trash,
                      size: 14,
                      color: cs.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _pickBackgroundImage(AppUser user) async {
    final file = await _bgService.pickImage(context);
    if (file == null || !mounted) return;

    setState(() => _isUploadingBg = true);

    final url = await _bgService.upload(userId: user.uid, imageFile: file);

    if (!mounted) return;
    setState(() {
      _isUploadingBg = false;
      if (url != null) {
        _draft = _draft.copyWith(backgroundImageUrl: url);
      }
    });
  }

  void _showUpgradeSnackbar(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.premiumRequired)),
    );
  }

  // ── Helpers ──

  String _presetLabel(CardThemePreset preset) {
    return switch (preset) {
      CardThemePreset.defaultRole => 'Default',
      CardThemePreset.dark => 'Dark',
      CardThemePreset.light => 'Light',
      CardThemePreset.neon => 'Neon',
      CardThemePreset.minimal => 'Minimal',
      CardThemePreset.holographicPro => 'Holo',
      CardThemePreset.carbon => 'Carbon',
      CardThemePreset.gold => 'Gold',
      CardThemePreset.galaxy => 'Galaxy',
    };
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: cs.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }
}
