import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/useme_theme.dart';
import '../../core/blocs/blocs_exports.dart';
import '../../l10n/app_localizations.dart';

/// Terms and conditions acceptance screen with app-consistent design
class TermsAcceptancePage extends StatefulWidget {
  final OnboardingTermsState state;

  const TermsAcceptancePage({super.key, required this.state});

  @override
  State<TermsAcceptancePage> createState() => _TermsAcceptancePageState();
}

class _TermsAcceptancePageState extends State<TermsAcceptancePage>
    with SingleTickerProviderStateMixin {
  static const String _termsUrl = 'https://useme.app/terms';
  static const String _privacyUrl = 'https://useme.app/privacy';

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

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userId =
            authState is AuthAuthenticatedState ? authState.user.id : '';

        return Stack(
          children: [
            // Blue gradient background
            _GradientBackground(
              controller: _floatController,
              isAccepted: widget.state.isAccepted,
            ),

            // Floating shapes
            _FloatingShapes(controller: _floatController),

            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Spacer(),

                    // Icon
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
                        l10n.onboardingTermsTitle,
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
                        l10n.onboardingTermsDesc,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Links
                    FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      delay: const Duration(milliseconds: 300),
                      child: _buildLinks(l10n),
                    ),

                    const Spacer(),

                    // Checkbox
                    FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      delay: const Duration(milliseconds: 400),
                      child: _buildCheckbox(l10n),
                    ),

                    const SizedBox(height: 24),

                    // Button
                    FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      delay: const Duration(milliseconds: 500),
                      child: SizedBox(
                        width: double.infinity,
                        child: _PrimaryButton(
                          label: l10n.onboardingLetsGo,
                          icon: FontAwesomeIcons.rocket,
                          isEnabled: widget.state.isAccepted,
                          onPressed: widget.state.isAccepted
                              ? () {
                                  context.read<OnboardingBloc>().add(
                                        CompleteOnboardingEvent(userId: userId),
                                      );
                                }
                              : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIcon() {
    final isAccepted = widget.state.isAccepted;

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
            color: isAccepted
                ? UseMeTheme.successColor.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.15),
            border: Border.all(
              color: isAccepted
                  ? UseMeTheme.successColor.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: FaIcon(
                isAccepted
                    ? FontAwesomeIcons.circleCheck
                    : FontAwesomeIcons.fileContract,
                key: ValueKey(isAccepted),
                size: 56,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLinks(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _GlassLinkButton(
          icon: FontAwesomeIcons.fileLines,
          label: l10n.onboardingTermsLink,
          onTap: () => _launchUrl(_termsUrl),
        ),
        const SizedBox(width: 16),
        _GlassLinkButton(
          icon: FontAwesomeIcons.shield,
          label: l10n.onboardingPrivacyLink,
          onTap: () => _launchUrl(_privacyUrl),
        ),
      ],
    );
  }

  Widget _buildCheckbox(AppLocalizations l10n) {
    final isAccepted = widget.state.isAccepted;

    return GestureDetector(
      onTap: () {
        context.read<OnboardingBloc>().add(
              ToggleTermsAcceptanceEvent(accepted: !isAccepted),
            );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isAccepted
                  ? UseMeTheme.successColor.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.1),
              border: Border.all(
                color: isAccepted
                    ? UseMeTheme.successColor.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.2),
                width: isAccepted ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:
                        isAccepted ? UseMeTheme.successColor : Colors.transparent,
                    border: Border.all(
                      color: isAccepted
                          ? UseMeTheme.successColor
                          : Colors.white.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: isAccepted
                      ? const Center(
                          child: FaIcon(
                            FontAwesomeIcons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    l10n.onboardingTermsAccept,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontWeight: isAccepted ? FontWeight.w600 : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Animated gradient background
class _GradientBackground extends StatelessWidget {
  final AnimationController controller;
  final bool isAccepted;

  const _GradientBackground({
    required this.controller,
    required this.isAccepted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isAccepted
                  ? [
                      UseMeTheme.primaryColor,
                      Color.lerp(
                        UseMeTheme.primaryColor,
                        UseMeTheme.successColor,
                        0.3 + controller.value * 0.1,
                      )!,
                      UseMeTheme.secondaryColor,
                    ]
                  : [
                      UseMeTheme.primaryColor,
                      Color.lerp(
                        UseMeTheme.primaryColor,
                        UseMeTheme.secondaryColor,
                        0.4 + controller.value * 0.2,
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
              top: -80 + controller.value * 20,
              right: -70,
              child: _FloatingCircle(size: 200, opacity: 0.07),
            ),
            Positioned(
              bottom: -60 - controller.value * 18,
              left: -80,
              child: _FloatingCircle(size: 180, opacity: 0.06),
            ),
            Positioned(
              top: size.height * 0.35 + controller.value * 10,
              left: 25,
              child: Container(
                width: 10,
                height: 10,
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

/// Glass link button
class _GlassLinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GlassLinkButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withValues(alpha: 0.1),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(icon, color: Colors.white, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
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
  final IconData icon;
  final bool isEnabled;
  final VoidCallback? onPressed;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.isEnabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: isEnabled
              ? UseMeTheme.successColor.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          child: InkWell(
            onTap: onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isEnabled
                      ? UseMeTheme.successColor.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.2),
                  width: isEnabled ? 2 : 1,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      icon,
                      color: isEnabled
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        color: isEnabled
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
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
