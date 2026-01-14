import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../config/useme_theme.dart';
import '../../core/blocs/blocs_exports.dart';
import '../../l10n/app_localizations.dart';

/// Permission screen for notification access with app-consistent design
class NotificationPermissionPage extends StatefulWidget {
  final OnboardingNotificationState state;

  const NotificationPermissionPage({super.key, required this.state});

  @override
  State<NotificationPermissionPage> createState() =>
      _NotificationPermissionPageState();
}

class _NotificationPermissionPageState extends State<NotificationPermissionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        // Blue gradient background
        _GradientBackground(controller: _floatController),

        // Floating shapes
        _FloatingShapes(controller: _floatController),

        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: _GlassButton(
                    onPressed:
                        widget.state.status == PermissionStatus.requesting
                            ? null
                            : () {
                                context.read<OnboardingBloc>().add(
                                      const SkipNotificationPermissionEvent(),
                                    );
                              },
                    child: Text(
                      l10n.onboardingLater,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Animated bell icon
                ZoomIn(
                  duration: const Duration(milliseconds: 500),
                  child: _buildIcon(),
                ),

                const SizedBox(height: 48),

                // Title
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    l10n.onboardingNotificationTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    l10n.onboardingNotificationDesc,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Status indicator
                if (widget.state.status == PermissionStatus.granted) ...[
                  const SizedBox(height: 24),
                  FadeIn(
                    child: _buildSuccessBadge(l10n),
                  ),
                ],

                const Spacer(),

                // Buttons
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 300),
                  child: _buildButtons(l10n),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    final isGranted = widget.state.status == PermissionStatus.granted;

    return ClipRRect(
      borderRadius: BorderRadius.circular(70),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isGranted
                ? UseMeTheme.successColor.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.15),
            border: Border.all(
              color: isGranted
                  ? UseMeTheme.successColor.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: FaIcon(
              isGranted
                  ? FontAwesomeIcons.circleCheck
                  : FontAwesomeIcons.bell,
              size: 56,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBadge(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: UseMeTheme.successColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: UseMeTheme.successColor.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(
            FontAwesomeIcons.circleCheck,
            size: 18,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Text(
            l10n.onboardingNotificationGranted,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(AppLocalizations l10n) {
    final isRequesting = widget.state.status == PermissionStatus.requesting;
    final isGranted = widget.state.status == PermissionStatus.granted;

    return Column(
      children: [
        // Primary action button
        SizedBox(
          width: double.infinity,
          child: _PrimaryButton(
            label: l10n.onboardingEnableNotifications,
            icon: isRequesting ? null : FontAwesomeIcons.bell,
            isLoading: isRequesting,
            isEnabled: !isRequesting && !isGranted,
            onPressed: isRequesting || isGranted
                ? null
                : () {
                    context.read<OnboardingBloc>().add(
                          const RequestNotificationPermissionEvent(),
                        );
                  },
          ),
        ),

        const SizedBox(height: 16),

        // Skip button
        TextButton(
          onPressed: isRequesting
              ? null
              : () {
                  context.read<OnboardingBloc>().add(
                        const SkipNotificationPermissionEvent(),
                      );
                },
          child: Text(
            l10n.onboardingLater,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated gradient background
class _GradientBackground extends StatelessWidget {
  final AnimationController controller;

  const _GradientBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                UseMeTheme.primaryColor,
                Color.lerp(
                  UseMeTheme.primaryColor,
                  UseMeTheme.secondaryColor,
                  0.5 + controller.value * 0.15,
                )!,
                UseMeTheme.secondaryColor,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Floating decorative shapes
class _FloatingShapes extends StatelessWidget {
  final AnimationController controller;

  const _FloatingShapes({required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -70 + controller.value * 18,
              right: -50,
              child: _FloatingCircle(size: 180, opacity: 0.07),
            ),
            Positioned(
              bottom: -40 - controller.value * 15,
              left: -60,
              child: _FloatingCircle(size: 160, opacity: 0.06),
            ),
            Positioned(
              top: size.height * 0.45 + controller.value * 12,
              right: 35,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: UseMeTheme.tertiaryColor.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FloatingCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _FloatingCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

/// Glass button
class _GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const _GlassButton({required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withValues(alpha: 0.15),
          child: InkWell(
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Primary action button
class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback? onPressed;

  const _PrimaryButton({
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withValues(alpha: isEnabled ? 0.25 : 0.1),
          child: InkWell(
            onTap: onPressed,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isEnabled ? 0.35 : 0.15),
                ),
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            FaIcon(
                              icon,
                              color: Colors.white.withValues(
                                alpha: isEnabled ? 1.0 : 0.5,
                              ),
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                          ],
                          Text(
                            label,
                            style: TextStyle(
                              color: Colors.white.withValues(
                                alpha: isEnabled ? 1.0 : 0.5,
                              ),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
