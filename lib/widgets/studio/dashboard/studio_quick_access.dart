import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/common/dashboard/dashboard_exports.dart';

/// Quick access row for studio dashboard
class StudioQuickAccess extends StatelessWidget {
  final AppLocalizations l10n;

  const StudioQuickAccess({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
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
            icon: FontAwesomeIcons.chartLine,
            label: l10n.stats,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
