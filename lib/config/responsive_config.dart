import 'package:flutter/material.dart';

/// Breakpoints pour le design responsive
/// Mobile-first approach
class Breakpoints {
  Breakpoints._();

  /// Mobile : < 600dp (phones)
  static const double mobile = 600;

  /// Tablet : 600-900dp (tablets, small laptops)
  static const double tablet = 900;

  /// Desktop : >= 900dp (laptops, desktops, large tablets)
  static const double desktop = 1200;

  /// Large desktop : >= 1200dp (large monitors)
  static const double largeDesktop = 1200;
}

/// Type d'écran basé sur la largeur
enum ScreenType { mobile, tablet, desktop }

/// Helper class pour le responsive design
class Responsive {
  Responsive._();

  /// Retourne le type d'écran actuel
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= Breakpoints.tablet) return ScreenType.desktop;
    if (width >= Breakpoints.mobile) return ScreenType.tablet;
    return ScreenType.mobile;
  }

  /// True si l'écran est mobile (< 600dp)
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < Breakpoints.mobile;

  /// True si l'écran est tablet (600-900dp)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= Breakpoints.mobile && width < Breakpoints.tablet;
  }

  /// True si l'écran est desktop (>= 900dp)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.tablet;

  /// True si l'écran est tablet ou plus grand
  static bool isTabletOrLarger(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.mobile;

  /// Retourne le nombre de colonnes pour les grilles
  static int gridColumns(BuildContext context) {
    final type = getScreenType(context);
    return switch (type) {
      ScreenType.desktop => 4,
      ScreenType.tablet => 3,
      ScreenType.mobile => 2,
    };
  }

  /// Retourne le padding horizontal adapté
  static double horizontalPadding(BuildContext context) {
    final type = getScreenType(context);
    return switch (type) {
      ScreenType.desktop => 32,
      ScreenType.tablet => 24,
      ScreenType.mobile => 16,
    };
  }

  /// Retourne le spacing entre éléments
  static double itemSpacing(BuildContext context) {
    final type = getScreenType(context);
    return switch (type) {
      ScreenType.desktop => 24,
      ScreenType.tablet => 20,
      ScreenType.mobile => 16,
    };
  }

  /// Largeur max du contenu (pour centrer sur grand écran)
  static const double maxContentWidth = 1200;

  /// Largeur max des formulaires
  static const double maxFormWidth = 600;

  /// Largeur max des cartes
  static const double maxCardWidth = 400;

  /// Hauteur de la barre de navigation flottante (incluant padding)
  /// Utilisé pour positionner les FAB au-dessus de la navbar
  static const double floatingNavHeight = 72;

  /// Padding pour les FAB au-dessus de la navbar flottante
  /// = floatingNavHeight + 8px de marge de securite
  static const double fabBottomOffset = 80;
}

/// Widget builder responsive
/// Permet de construire différents layouts selon la taille d'écran
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final type = Responsive.getScreenType(context);

    return switch (type) {
      ScreenType.desktop => (desktop ?? tablet ?? mobile)(context),
      ScreenType.tablet => (tablet ?? mobile)(context),
      ScreenType.mobile => mobile(context),
    };
  }
}

/// Widget qui contraint le contenu à une largeur max et le centre
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = Responsive.maxContentWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = Responsive.horizontalPadding(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ??
              EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}

/// Extension pour faciliter l'accès aux helpers responsive
extension ResponsiveContext on BuildContext {
  /// Type d'écran actuel
  ScreenType get screenType => Responsive.getScreenType(this);

  /// True si mobile
  bool get isMobile => Responsive.isMobile(this);

  /// True si tablet
  bool get isTablet => Responsive.isTablet(this);

  /// True si desktop
  bool get isDesktop => Responsive.isDesktop(this);

  /// True si tablet ou plus grand
  bool get isTabletOrLarger => Responsive.isTabletOrLarger(this);

  /// Nombre de colonnes pour les grilles
  int get gridColumns => Responsive.gridColumns(this);

  /// Padding horizontal adapté
  double get horizontalPadding => Responsive.horizontalPadding(this);

  /// Spacing entre éléments
  double get itemSpacing => Responsive.itemSpacing(this);
}
