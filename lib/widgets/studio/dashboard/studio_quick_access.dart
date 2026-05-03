import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:uzme/config/responsive_config.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/routing/app_routes.dart';
import 'package:uzme/widgets/card/digital_card_sheet.dart';
import 'package:uzme/widgets/common/dashboard/dashboard_exports.dart';

/// Quick access row for studio dashboard
class StudioQuickAccess extends StatelessWidget {
  final AppLocalizations l10n;

  const StudioQuickAccess({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final pills = [
      DashboardQuickPill(
        icon: FontAwesomeIcons.plus,
        label: l10n.session,
        isPrimary: true,
        onTap: () => context.push(AppRoutes.sessionAdd),
      ),
      DashboardQuickPill(
        icon: FontAwesomeIcons.userPlus,
        label: l10n.artist,
        onTap: () => context.push(AppRoutes.artistAdd),
      ),
      DashboardQuickPill(
        icon: FontAwesomeIcons.calendarDays,
        label: l10n.planning,
        onTap: () => context.push(AppRoutes.sessions),
      ),
      DashboardQuickPill(
        icon: FontAwesomeIcons.idCard,
        label: l10n.myCard,
        onTap: () => DigitalCardSheet.show(context),
      ),
    ];

    // Sur tablet+, afficher en Row avec espacement uniforme
    if (context.isTabletOrLarger) {
      return Row(
        children: pills
            .map((pill) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: pill,
                  ),
                ))
            .toList(),
      );
    }

    // Sur mobile, ListView horizontal scrollable
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: pills,
      ),
    );
  }
}
