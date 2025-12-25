import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/l10n/app_localizations.dart';
import '../models/tip_item.dart';

/// Tips and guides data for each user role
class TipsData {
  TipsData._();

  // ============ ARTISTE ============
  static List<TipSection> artistTips(AppLocalizations l10n) => [
    TipSection(
      title: l10n.tipsSectionGettingStarted,
      icon: FontAwesomeIcons.rocket,
      color: Colors.blue,
      tips: [
        TipItem(
          title: l10n.tipExploreMapTitle,
          description: l10n.tipExploreMapDesc,
          icon: FontAwesomeIcons.mapLocationDot,
        ),
        TipItem(
          title: l10n.tipCompleteProfileTitle,
          description: l10n.tipCompleteProfileDesc,
          icon: FontAwesomeIcons.userPen,
        ),
      ],
    ),
    TipSection(
      title: l10n.tipsSectionBookings,
      icon: FontAwesomeIcons.calendarCheck,
      color: Colors.green,
      tips: [
        TipItem(
          title: l10n.tipChooseSlotTitle,
          description: l10n.tipChooseSlotDesc,
          icon: FontAwesomeIcons.clock,
        ),
        TipItem(
          title: l10n.tipSelectEngineerTitle,
          description: l10n.tipSelectEngineerDesc,
          icon: FontAwesomeIcons.userGear,
        ),
        TipItem(
          title: l10n.tipPrepareSessionTitle,
          description: l10n.tipPrepareSessionDesc,
          icon: FontAwesomeIcons.clipboard,
        ),
      ],
    ),
    TipSection(
      title: l10n.tipsSectionProTips,
      icon: FontAwesomeIcons.wandMagicSparkles,
      color: Colors.purple,
      tips: [
        TipItem(
          title: l10n.tipBookAdvanceTitle,
          description: l10n.tipBookAdvanceDesc,
          icon: FontAwesomeIcons.calendarPlus,
          iconColor: Colors.orange,
        ),
        TipItem(
          title: l10n.tipManageFavoritesTitle,
          description: l10n.tipManageFavoritesDesc,
          icon: FontAwesomeIcons.heart,
          iconColor: Colors.red,
        ),
        TipItem(
          title: l10n.tipTrackSessionsTitle,
          description: l10n.tipTrackSessionsDesc,
          icon: FontAwesomeIcons.clockRotateLeft,
        ),
      ],
    ),
    TipSection(
      title: l10n.tipsSectionAIAssistant,
      icon: FontAwesomeIcons.robot,
      color: Colors.deepPurple,
      tips: [
        TipItem(
          title: l10n.tipAIAssistantTitle,
          description: l10n.tipAIAssistantDesc,
          icon: FontAwesomeIcons.commentDots,
          iconColor: Colors.purple,
        ),
        TipItem(
          title: l10n.tipAIActionsTitle,
          description: l10n.tipAIActionsArtistDesc,
          icon: FontAwesomeIcons.wandMagicSparkles,
          iconColor: Colors.blue,
        ),
        TipItem(
          title: l10n.tipAIContextTitle,
          description: l10n.tipAIContextDesc,
          icon: FontAwesomeIcons.userCheck,
          iconColor: Colors.green,
        ),
      ],
    ),
  ];

  // ============ INGENIEUR ============
  static List<TipSection> engineerTips(AppLocalizations l10n) => [
    TipSection(
      title: l10n.tipsSectionSetup,
      icon: FontAwesomeIcons.gear,
      color: Colors.blue,
      tips: [
        TipItem(
          title: l10n.tipSetScheduleTitle,
          description: l10n.tipSetScheduleDesc,
          icon: FontAwesomeIcons.calendarDays,
        ),
        TipItem(
          title: l10n.tipAddUnavailabilityTitle,
          description: l10n.tipAddUnavailabilityDesc,
          icon: FontAwesomeIcons.calendarXmark,
        ),
      ],
    ),
    TipSection(
      title: l10n.tipsSectionSessions,
      icon: FontAwesomeIcons.microphone,
      color: Colors.green,
      tips: [
        TipItem(
          title: l10n.tipViewSessionsTitle,
          description: l10n.tipViewSessionsDesc,
          icon: FontAwesomeIcons.listCheck,
        ),
        TipItem(
          title: l10n.tipStartSessionTitle,
          description: l10n.tipStartSessionDesc,
          icon: FontAwesomeIcons.play,
        ),
        TipItem(
          title: l10n.tipSessionNotesTitle,
          description: l10n.tipSessionNotesDesc,
          icon: FontAwesomeIcons.penToSquare,
        ),
      ],
    ),
    TipSection(
      title: l10n.tipsSectionTips,
      icon: FontAwesomeIcons.lightbulb,
      color: Colors.orange,
      tips: [
        TipItem(
          title: l10n.tipStayUpdatedTitle,
          description: l10n.tipStayUpdatedDesc,
          icon: FontAwesomeIcons.rotate,
        ),
        TipItem(
          title: l10n.tipProfileMattersTitle,
          description: l10n.tipProfileMattersDesc,
          icon: FontAwesomeIcons.idCard,
        ),
      ],
    ),
    TipSection(
      title: l10n.tipsSectionAIAssistant,
      icon: FontAwesomeIcons.robot,
      color: Colors.deepPurple,
      tips: [
        TipItem(
          title: l10n.tipAIAssistantTitle,
          description: l10n.tipAIAssistantDesc,
          icon: FontAwesomeIcons.commentDots,
          iconColor: Colors.purple,
        ),
        TipItem(
          title: l10n.tipAIActionsTitle,
          description: l10n.tipAIActionsEngineerDesc,
          icon: FontAwesomeIcons.wandMagicSparkles,
          iconColor: Colors.blue,
        ),
        TipItem(
          title: l10n.tipAIContextTitle,
          description: l10n.tipAIContextDesc,
          icon: FontAwesomeIcons.userCheck,
          iconColor: Colors.green,
        ),
      ],
    ),
  ];

  // ============ STUDIO ============
  static List<TipSection> studioTips(AppLocalizations l10n) => [
    TipSection(
      title: l10n.tipsSectionStudioSetup,
      icon: FontAwesomeIcons.buildingUser,
      color: Colors.blue,
      tips: [
        TipItem(
          title: l10n.tipCompleteStudioProfileTitle,
          description: l10n.tipCompleteStudioProfileDesc,
          icon: FontAwesomeIcons.images,
        ),
        TipItem(
          title: l10n.tipSetStudioHoursTitle,
          description: l10n.tipSetStudioHoursDesc,
          icon: FontAwesomeIcons.clock,
        ),
        TipItem(
          title: l10n.tipAddServicesTitle,
          description: l10n.tipAddServicesDesc,
          icon: FontAwesomeIcons.tags,
        ),
      ],
    ),
    TipSection(
      title: l10n.tipsSectionTeamManagement,
      icon: FontAwesomeIcons.users,
      color: Colors.green,
      tips: [
        TipItem(
          title: l10n.tipInviteEngineersTitle,
          description: l10n.tipInviteEngineersDesc,
          icon: FontAwesomeIcons.userPlus,
        ),
        TipItem(
          title: l10n.tipManageAvailabilitiesTitle,
          description: l10n.tipManageAvailabilitiesDesc,
          icon: FontAwesomeIcons.calendarCheck,
        ),
        TipItem(
          title: l10n.tipAssignSessionsTitle,
          description: l10n.tipAssignSessionsDesc,
          icon: FontAwesomeIcons.userGear,
        ),
      ],
    ),
    TipSection(
      title: l10n.tipsSectionBookings,
      icon: FontAwesomeIcons.calendarDays,
      color: Colors.purple,
      tips: [
        TipItem(
          title: l10n.tipManageRequestsTitle,
          description: l10n.tipManageRequestsDesc,
          icon: FontAwesomeIcons.bell,
          iconColor: Colors.orange,
        ),
        TipItem(
          title: l10n.tipInviteArtistsTitle,
          description: l10n.tipInviteArtistsDesc,
          icon: FontAwesomeIcons.envelopeOpenText,
        ),
        TipItem(
          title: l10n.tipTrackActivityTitle,
          description: l10n.tipTrackActivityDesc,
          icon: FontAwesomeIcons.chartLine,
        ),
      ],
    ),
    TipSection(
      title: l10n.tipsSectionVisibility,
      icon: FontAwesomeIcons.eye,
      color: Colors.orange,
      tips: [
        TipItem(
          title: l10n.tipBecomePartnerTitle,
          description: l10n.tipBecomePartnerDesc,
          icon: FontAwesomeIcons.handshake,
          iconColor: Colors.green,
        ),
        TipItem(
          title: l10n.tipEncourageReviewsTitle,
          description: l10n.tipEncourageReviewsDesc,
          icon: FontAwesomeIcons.star,
          iconColor: Colors.amber,
        ),
      ],
    ),
    TipSection(
      title: l10n.tipsSectionAIAssistant,
      icon: FontAwesomeIcons.robot,
      color: Colors.deepPurple,
      tips: [
        TipItem(
          title: l10n.tipAIAssistantTitle,
          description: l10n.tipAIAssistantDesc,
          icon: FontAwesomeIcons.commentDots,
          iconColor: Colors.purple,
        ),
        TipItem(
          title: l10n.tipAIActionsTitle,
          description: l10n.tipAIActionsStudioDesc,
          icon: FontAwesomeIcons.wandMagicSparkles,
          iconColor: Colors.blue,
        ),
        TipItem(
          title: l10n.tipAIContextTitle,
          description: l10n.tipAIContextDesc,
          icon: FontAwesomeIcons.userCheck,
          iconColor: Colors.green,
        ),
      ],
    ),
  ];
}
