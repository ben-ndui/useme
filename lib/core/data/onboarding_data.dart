import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/onboarding_page.dart';

/// Static data for onboarding pages based on user role
class OnboardingData {
  /// Get onboarding pages for a specific role
  static List<OnboardingPage> getPagesForRole(String role) {
    return [
      // Page 1: Welcome (all roles)
      const OnboardingPage(
        titleKey: 'onboardingWelcomeTitle',
        descriptionKey: 'onboardingWelcomeDesc',
        icon: FontAwesomeIcons.music,
        iconColor: Colors.deepPurple,
      ),

      // Pages 2-3: Role-specific
      ..._getRoleSpecificPages(role),

      // Page 4: AI Assistant (all roles)
      const OnboardingPage(
        titleKey: 'onboardingAITitle',
        descriptionKey: 'onboardingAIDesc',
        icon: FontAwesomeIcons.robot,
        iconColor: Colors.teal,
      ),

      // Page 5: Ready (all roles)
      const OnboardingPage(
        titleKey: 'onboardingReadyTitle',
        descriptionKey: 'onboardingReadyDesc',
        icon: FontAwesomeIcons.circleCheck,
        iconColor: Colors.green,
      ),
    ];
  }

  static List<OnboardingPage> _getRoleSpecificPages(String role) {
    switch (role) {
      case 'admin':
      case 'superAdmin':
        return const [
          OnboardingPage(
            titleKey: 'onboardingStudioSessionsTitle',
            descriptionKey: 'onboardingStudioSessionsDesc',
            icon: FontAwesomeIcons.calendarDays,
            iconColor: Colors.blue,
          ),
          OnboardingPage(
            titleKey: 'onboardingStudioTeamTitle',
            descriptionKey: 'onboardingStudioTeamDesc',
            icon: FontAwesomeIcons.userGroup,
            iconColor: Colors.orange,
          ),
        ];

      case 'worker':
        return const [
          OnboardingPage(
            titleKey: 'onboardingEngineerSessionsTitle',
            descriptionKey: 'onboardingEngineerSessionsDesc',
            icon: FontAwesomeIcons.sliders,
            iconColor: Colors.blue,
          ),
          OnboardingPage(
            titleKey: 'onboardingEngineerAvailabilityTitle',
            descriptionKey: 'onboardingEngineerAvailabilityDesc',
            icon: FontAwesomeIcons.calendarCheck,
            iconColor: Colors.orange,
          ),
        ];

      case 'client':
      default:
        return const [
          OnboardingPage(
            titleKey: 'onboardingArtistSearchTitle',
            descriptionKey: 'onboardingArtistSearchDesc',
            icon: FontAwesomeIcons.magnifyingGlass,
            iconColor: Colors.blue,
          ),
          OnboardingPage(
            titleKey: 'onboardingArtistBookingTitle',
            descriptionKey: 'onboardingArtistBookingDesc',
            icon: FontAwesomeIcons.calendarPlus,
            iconColor: Colors.orange,
          ),
        ];
    }
  }

  /// Get location permission description based on role
  static String getLocationDescriptionKey(String role) {
    switch (role) {
      case 'admin':
      case 'superAdmin':
        return 'onboardingLocationDescStudio';
      default:
        return 'onboardingLocationDescArtist';
    }
  }
}
