import 'package:flutter/material.dart';
import 'package:useme/config/useme_theme.dart';

/// Widget de chargement avec le logo de l'application.
/// Utilisé pour les loaders plein écran et les states de chargement.
class AppLoader extends StatelessWidget {
  /// Taille du logo (par défaut 80)
  final double size;

  /// Afficher le texte "Chargement..." sous le logo
  final bool showText;

  /// Texte personnalisé à afficher
  final String? text;

  /// Couleur de fond (null = transparent)
  final Color? backgroundColor;

  /// Afficher le loader en plein écran avec Scaffold
  final bool fullScreen;

  const AppLoader({
    super.key,
    this.size = 80,
    this.showText = false,
    this.text,
    this.backgroundColor,
    this.fullScreen = false,
  });

  /// Constructeur pour un loader plein écran
  const AppLoader.fullScreen({
    super.key,
    this.size = 100,
    this.showText = true,
    this.text,
    this.backgroundColor,
  }) : fullScreen = true;

  /// Constructeur pour un loader compact (dans une liste, etc.)
  const AppLoader.compact({
    super.key,
    this.showText = false,
    this.text,
    this.backgroundColor,
    this.fullScreen = false,
  }) : size = 48;

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    if (fullScreen) {
      return Scaffold(
        backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: content),
      );
    }

    if (backgroundColor != null) {
      return Container(
        color: backgroundColor,
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo avec animation de pulse
        _AnimatedLogo(size: size),
        if (showText || text != null) ...[
          const SizedBox(height: 16),
          Text(
            text ?? 'Chargement...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// Logo animé avec effet de pulse
class _AnimatedLogo extends StatefulWidget {
  final double size;

  const _AnimatedLogo({required this.size});

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.size * 0.25),
                boxShadow: [
                  BoxShadow(
                    color: UseMeTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.size * 0.25),
                child: Image.asset(
                  'assets/logo/playstore.png',
                  width: widget.size,
                  height: widget.size,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
