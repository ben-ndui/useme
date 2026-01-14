import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../config/useme_theme.dart';
import '../../core/blocs/blocs_exports.dart';
import '../../core/data/onboarding_data.dart';
import '../../core/models/onboarding_page.dart';
import '../../l10n/app_localizations.dart';

/// Page showing onboarding content slides with app-consistent design
class OnboardingContentPage extends StatefulWidget {
  final OnboardingContentState state;

  const OnboardingContentPage({super.key, required this.state});

  @override
  State<OnboardingContentPage> createState() => _OnboardingContentPageState();
}

class _OnboardingContentPageState extends State<OnboardingContentPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late List<OnboardingPage> _pages;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.state.currentPage);
    _pages = OnboardingData.getPagesForRole(widget.state.role);

    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(OnboardingContentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentPage != widget.state.currentPage) {
      _pageController.animateToPage(
        widget.state.currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
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

        // Main content
        SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _GlassButton(
                    onPressed: () {
                      context.read<OnboardingBloc>().add(
                            const SkipToPermissionsEvent(),
                          );
                    },
                    child: Text(
                      l10n.onboardingSkip,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              // PageView content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    final currentPage = widget.state.currentPage;
                    if (index > currentPage) {
                      context.read<OnboardingBloc>().add(const NextPageEvent());
                    } else if (index < currentPage) {
                      context
                          .read<OnboardingBloc>()
                          .add(const PreviousPageEvent());
                    }
                  },
                  itemBuilder: (context, index) {
                    return _OnboardingSlide(
                      page: _pages[index],
                      l10n: l10n,
                    );
                  },
                ),
              ),

              // Page indicator
              _PageIndicator(
                currentPage: widget.state.currentPage,
                totalPages: widget.state.totalPages,
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Row(
                  children: [
                    if (!widget.state.isFirstPage)
                      FadeInLeft(
                        duration: const Duration(milliseconds: 300),
                        child: _GlassIconButton(
                          icon: FontAwesomeIcons.arrowLeft,
                          onPressed: () {
                            context
                                .read<OnboardingBloc>()
                                .add(const PreviousPageEvent());
                          },
                        ),
                      ),
                    if (!widget.state.isFirstPage) const SizedBox(width: 16),
                    Expanded(
                      child: _PrimaryButton(
                        label: widget.state.isLastPage
                            ? l10n.onboardingGetStarted
                            : l10n.onboardingNext,
                        onPressed: () {
                          context
                              .read<OnboardingBloc>()
                              .add(const NextPageEvent());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                UseMeTheme.primaryColor,
                Color.lerp(
                  UseMeTheme.primaryColor,
                  UseMeTheme.secondaryColor,
                  0.3 + controller.value * 0.2,
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
            // Large circle top right
            Positioned(
              top: -80 + controller.value * 20,
              right: -60,
              child: _FloatingCircle(size: 200, opacity: 0.08),
            ),
            // Medium circle bottom left
            Positioned(
              bottom: -40 - controller.value * 15,
              left: -80,
              child: _FloatingCircle(size: 180, opacity: 0.06),
            ),
            // Small circle middle
            Positioned(
              top: size.height * 0.4 + controller.value * 10,
              right: 40,
              child: _FloatingCircle(size: 60, opacity: 0.1),
            ),
            // Accent circle
            Positioned(
              top: size.height * 0.25 - controller.value * 8,
              left: 30,
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

/// Single slide content
class _OnboardingSlide extends StatelessWidget {
  final OnboardingPage page;
  final AppLocalizations l10n;

  const _OnboardingSlide({
    required this.page,
    required this.l10n,
  });

  String _getLocalizedString(String key) {
    switch (key) {
      case 'onboardingWelcomeTitle':
        return l10n.onboardingWelcomeTitle;
      case 'onboardingWelcomeDesc':
        return l10n.onboardingWelcomeDesc;
      case 'onboardingStudioSessionsTitle':
        return l10n.onboardingStudioSessionsTitle;
      case 'onboardingStudioSessionsDesc':
        return l10n.onboardingStudioSessionsDesc;
      case 'onboardingStudioTeamTitle':
        return l10n.onboardingStudioTeamTitle;
      case 'onboardingStudioTeamDesc':
        return l10n.onboardingStudioTeamDesc;
      case 'onboardingEngineerSessionsTitle':
        return l10n.onboardingEngineerSessionsTitle;
      case 'onboardingEngineerSessionsDesc':
        return l10n.onboardingEngineerSessionsDesc;
      case 'onboardingEngineerAvailabilityTitle':
        return l10n.onboardingEngineerAvailabilityTitle;
      case 'onboardingEngineerAvailabilityDesc':
        return l10n.onboardingEngineerAvailabilityDesc;
      case 'onboardingArtistSearchTitle':
        return l10n.onboardingArtistSearchTitle;
      case 'onboardingArtistSearchDesc':
        return l10n.onboardingArtistSearchDesc;
      case 'onboardingArtistBookingTitle':
        return l10n.onboardingArtistBookingTitle;
      case 'onboardingArtistBookingDesc':
        return l10n.onboardingArtistBookingDesc;
      case 'onboardingAITitle':
        return l10n.onboardingAITitle;
      case 'onboardingAIDesc':
        return l10n.onboardingAIDesc;
      case 'onboardingReadyTitle':
        return l10n.onboardingReadyTitle;
      case 'onboardingReadyDesc':
        return l10n.onboardingReadyDesc;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container with glass effect
          ZoomIn(
            duration: const Duration(milliseconds: 500),
            child: _GlassIconContainer(
              icon: page.icon,
              color: page.iconColor ?? UseMeTheme.tertiaryColor,
            ),
          ),
          const SizedBox(height: 48),
          // Title
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 150),
            child: Text(
              _getLocalizedString(page.titleKey),
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
            delay: const Duration(milliseconds: 250),
            child: Text(
              _getLocalizedString(page.descriptionKey),
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Glassmorphism icon container
class _GlassIconContainer extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _GlassIconContainer({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(70),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 56,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Page indicator dots
class _PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _PageIndicator({
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalPages, (index) {
          final isActive = index == currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.35),
            ),
          );
        }),
      ),
    );
  }
}

/// Glass button
class _GlassButton extends StatelessWidget {
  final VoidCallback onPressed;
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

/// Glass icon button
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _GlassIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withValues(alpha: 0.15),
          child: InkWell(
            onTap: onPressed,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
              child: Center(
                child: FaIcon(icon, color: Colors.white, size: 20),
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
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withValues(alpha: 0.25),
          child: InkWell(
            onTap: onPressed,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const FaIcon(
                      FontAwesomeIcons.arrowRight,
                      color: Colors.white,
                      size: 16,
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
