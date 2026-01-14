import 'package:flutter/material.dart';
import 'package:smoothandesign_package/core/widgets/feedback/app_loader.dart' as pkg;

/// AppLoader Use Me avec le logo par défaut.
/// Wrapper autour du package pour garder la compatibilité.
class AppLoader extends StatelessWidget {
  final double size;
  final bool showText;
  final String? text;
  final Color? backgroundColor;
  final bool fullScreen;

  const AppLoader({
    super.key,
    this.size = 80,
    this.showText = false,
    this.text,
    this.backgroundColor,
    this.fullScreen = false,
  });

  const AppLoader.fullScreen({
    super.key,
    this.size = 100,
    this.showText = true,
    this.text,
    this.backgroundColor,
  }) : fullScreen = true;

  const AppLoader.compact({
    super.key,
    this.showText = false,
    this.text,
    this.backgroundColor,
    this.fullScreen = false,
  }) : size = 48;

  @override
  Widget build(BuildContext context) {
    if (fullScreen) {
      return pkg.AppLoader.fullScreen(
        logoPath: 'assets/logo/playstore.png',
        size: size,
        showText: showText,
        text: text,
        backgroundColor: backgroundColor,
      );
    }

    return pkg.AppLoader(
      logoPath: 'assets/logo/playstore.png',
      size: size,
      showText: showText,
      text: text,
      backgroundColor: backgroundColor,
    );
  }
}
