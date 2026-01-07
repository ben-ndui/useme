import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/l10n/app_localizations.dart';
import '../models/tip_item.dart';

/// AI Assistant guide data for each user role
class AIGuideData {
  AIGuideData._();

  // ============ ARTISTE ============
  static List<TipSection> artistGuide(AppLocalizations l10n) => [
    TipSection(
      title: l10n.aiGuideIntroTitle,
      icon: FontAwesomeIcons.robot,
      color: Colors.deepPurple,
      tips: [
        TipItem(
          title: l10n.aiGuideWhatIsTitle,
          description: l10n.aiGuideWhatIsDesc,
          icon: FontAwesomeIcons.circleInfo,
          iconColor: Colors.blue,
        ),
        TipItem(
          title: l10n.aiGuideConfirmTitle,
          description: l10n.aiGuideConfirmDesc,
          icon: FontAwesomeIcons.shieldHalved,
          iconColor: Colors.green,
        ),
      ],
    ),
    TipSection(
      title: l10n.aiGuideReadTitle,
      icon: FontAwesomeIcons.magnifyingGlass,
      color: Colors.blue,
      tips: [
        TipItem(
          title: l10n.aiGuideSessionsTitle,
          description: l10n.aiGuideArtistSessionsDesc,
          icon: FontAwesomeIcons.calendarCheck,
        ),
        TipItem(
          title: l10n.aiGuideAvailabilityTitle,
          description: l10n.aiGuideAvailabilityDesc,
          icon: FontAwesomeIcons.clock,
        ),
        TipItem(
          title: l10n.aiGuideConversationsTitle,
          description: l10n.aiGuideConversationsDesc,
          icon: FontAwesomeIcons.comments,
        ),
      ],
    ),
    TipSection(
      title: l10n.aiGuideActionsTitle,
      icon: FontAwesomeIcons.wandMagicSparkles,
      color: Colors.orange,
      tips: [
        TipItem(
          title: l10n.aiGuideBookingTitle,
          description: l10n.aiGuideBookingDesc,
          icon: FontAwesomeIcons.calendarPlus,
          iconColor: Colors.green,
        ),
        TipItem(
          title: l10n.aiGuideFavoritesTitle,
          description: l10n.aiGuideFavoritesDesc,
          icon: FontAwesomeIcons.heart,
          iconColor: Colors.red,
        ),
        TipItem(
          title: l10n.aiGuideSearchStudiosTitle,
          description: l10n.aiGuideSearchStudiosDesc,
          icon: FontAwesomeIcons.searchLocation,
          iconColor: Colors.purple,
        ),
        TipItem(
          title: l10n.aiGuideSendMessageTitle,
          description: l10n.aiGuideSendMessageDesc,
          icon: FontAwesomeIcons.paperPlane,
          iconColor: Colors.blue,
        ),
      ],
    ),
    TipSection(
      title: l10n.aiGuideExamplesTitle,
      icon: FontAwesomeIcons.lightbulb,
      color: Colors.amber,
      tips: [
        TipItem(
          title: l10n.aiGuideExample1ArtistTitle,
          description: l10n.aiGuideExample1ArtistDesc,
          icon: FontAwesomeIcons.quoteLeft,
        ),
        TipItem(
          title: l10n.aiGuideExample2ArtistTitle,
          description: l10n.aiGuideExample2ArtistDesc,
          icon: FontAwesomeIcons.quoteLeft,
        ),
        TipItem(
          title: l10n.aiGuideExample3ArtistTitle,
          description: l10n.aiGuideExample3ArtistDesc,
          icon: FontAwesomeIcons.quoteLeft,
        ),
      ],
    ),
  ];

  // ============ INGENIEUR ============
  static List<TipSection> engineerGuide(AppLocalizations l10n) => [
    TipSection(
      title: l10n.aiGuideIntroTitle,
      icon: FontAwesomeIcons.robot,
      color: Colors.deepPurple,
      tips: [
        TipItem(
          title: l10n.aiGuideWhatIsTitle,
          description: l10n.aiGuideWhatIsDesc,
          icon: FontAwesomeIcons.circleInfo,
          iconColor: Colors.blue,
        ),
        TipItem(
          title: l10n.aiGuideConfirmTitle,
          description: l10n.aiGuideConfirmDesc,
          icon: FontAwesomeIcons.shieldHalved,
          iconColor: Colors.green,
        ),
      ],
    ),
    TipSection(
      title: l10n.aiGuideReadTitle,
      icon: FontAwesomeIcons.magnifyingGlass,
      color: Colors.blue,
      tips: [
        TipItem(
          title: l10n.aiGuideSessionsTitle,
          description: l10n.aiGuideEngineerSessionsDesc,
          icon: FontAwesomeIcons.calendarCheck,
        ),
        TipItem(
          title: l10n.aiGuideTimeOffTitle,
          description: l10n.aiGuideTimeOffDesc,
          icon: FontAwesomeIcons.calendarXmark,
        ),
        TipItem(
          title: l10n.aiGuideConversationsTitle,
          description: l10n.aiGuideConversationsDesc,
          icon: FontAwesomeIcons.comments,
        ),
      ],
    ),
    TipSection(
      title: l10n.aiGuideActionsTitle,
      icon: FontAwesomeIcons.wandMagicSparkles,
      color: Colors.orange,
      tips: [
        TipItem(
          title: l10n.aiGuideStartSessionTitle,
          description: l10n.aiGuideStartSessionDesc,
          icon: FontAwesomeIcons.play,
          iconColor: Colors.green,
        ),
        TipItem(
          title: l10n.aiGuideCompleteSessionTitle,
          description: l10n.aiGuideCompleteSessionDesc,
          icon: FontAwesomeIcons.flagCheckered,
          iconColor: Colors.blue,
        ),
        TipItem(
          title: l10n.aiGuideRespondProposalTitle,
          description: l10n.aiGuideRespondProposalDesc,
          icon: FontAwesomeIcons.handshake,
          iconColor: Colors.purple,
        ),
        TipItem(
          title: l10n.aiGuideManageTimeOffTitle,
          description: l10n.aiGuideManageTimeOffDesc,
          icon: FontAwesomeIcons.calendarMinus,
          iconColor: Colors.orange,
        ),
      ],
    ),
    TipSection(
      title: l10n.aiGuideExamplesTitle,
      icon: FontAwesomeIcons.lightbulb,
      color: Colors.amber,
      tips: [
        TipItem(
          title: l10n.aiGuideExample1EngineerTitle,
          description: l10n.aiGuideExample1EngineerDesc,
          icon: FontAwesomeIcons.quoteLeft,
        ),
        TipItem(
          title: l10n.aiGuideExample2EngineerTitle,
          description: l10n.aiGuideExample2EngineerDesc,
          icon: FontAwesomeIcons.quoteLeft,
        ),
        TipItem(
          title: l10n.aiGuideExample3EngineerTitle,
          description: l10n.aiGuideExample3EngineerDesc,
          icon: FontAwesomeIcons.quoteLeft,
        ),
      ],
    ),
  ];

  // ============ STUDIO ============
  static List<TipSection> studioGuide(AppLocalizations l10n) => [
    TipSection(
      title: l10n.aiGuideIntroTitle,
      icon: FontAwesomeIcons.robot,
      color: Colors.deepPurple,
      tips: [
        TipItem(
          title: l10n.aiGuideWhatIsTitle,
          description: l10n.aiGuideWhatIsDesc,
          icon: FontAwesomeIcons.circleInfo,
          iconColor: Colors.blue,
        ),
        TipItem(
          title: l10n.aiGuideConfirmTitle,
          description: l10n.aiGuideConfirmDesc,
          icon: FontAwesomeIcons.shieldHalved,
          iconColor: Colors.green,
        ),
      ],
    ),
    TipSection(
      title: l10n.aiGuideReadTitle,
      icon: FontAwesomeIcons.magnifyingGlass,
      color: Colors.blue,
      tips: [
        TipItem(
          title: l10n.aiGuideSessionsTitle,
          description: l10n.aiGuideStudioSessionsDesc,
          icon: FontAwesomeIcons.calendarCheck,
        ),
        TipItem(
          title: l10n.aiGuidePendingTitle,
          description: l10n.aiGuidePendingDesc,
          icon: FontAwesomeIcons.bell,
          iconColor: Colors.orange,
        ),
        TipItem(
          title: l10n.aiGuideStatsTitle,
          description: l10n.aiGuideStatsDesc,
          icon: FontAwesomeIcons.chartLine,
        ),
        TipItem(
          title: l10n.aiGuideRevenueTitle,
          description: l10n.aiGuideRevenueDesc,
          icon: FontAwesomeIcons.euroSign,
          iconColor: Colors.green,
        ),
        TipItem(
          title: l10n.aiGuideTeamTitle,
          description: l10n.aiGuideTeamDesc,
          icon: FontAwesomeIcons.users,
        ),
      ],
    ),
    TipSection(
      title: l10n.aiGuideActionsTitle,
      icon: FontAwesomeIcons.wandMagicSparkles,
      color: Colors.orange,
      tips: [
        TipItem(
          title: l10n.aiGuideAcceptDeclineTitle,
          description: l10n.aiGuideAcceptDeclineDesc,
          icon: FontAwesomeIcons.check,
          iconColor: Colors.green,
        ),
        TipItem(
          title: l10n.aiGuideRescheduleTitle,
          description: l10n.aiGuideRescheduleDesc,
          icon: FontAwesomeIcons.calendarDay,
          iconColor: Colors.blue,
        ),
        TipItem(
          title: l10n.aiGuideAssignEngineerTitle,
          description: l10n.aiGuideAssignEngineerDesc,
          icon: FontAwesomeIcons.userGear,
          iconColor: Colors.purple,
        ),
        TipItem(
          title: l10n.aiGuideCreateSessionTitle,
          description: l10n.aiGuideCreateSessionDesc,
          icon: FontAwesomeIcons.calendarPlus,
        ),
        TipItem(
          title: l10n.aiGuideBlockSlotsTitle,
          description: l10n.aiGuideBlockSlotsDesc,
          icon: FontAwesomeIcons.ban,
          iconColor: Colors.red,
        ),
        TipItem(
          title: l10n.aiGuideManageServicesTitle,
          description: l10n.aiGuideManageServicesDesc,
          icon: FontAwesomeIcons.tags,
        ),
      ],
    ),
    TipSection(
      title: l10n.aiGuideExamplesTitle,
      icon: FontAwesomeIcons.lightbulb,
      color: Colors.amber,
      tips: [
        TipItem(
          title: l10n.aiGuideExample1StudioTitle,
          description: l10n.aiGuideExample1StudioDesc,
          icon: FontAwesomeIcons.quoteLeft,
        ),
        TipItem(
          title: l10n.aiGuideExample2StudioTitle,
          description: l10n.aiGuideExample2StudioDesc,
          icon: FontAwesomeIcons.quoteLeft,
        ),
        TipItem(
          title: l10n.aiGuideExample3StudioTitle,
          description: l10n.aiGuideExample3StudioDesc,
          icon: FontAwesomeIcons.quoteLeft,
        ),
      ],
    ),
  ];
}
