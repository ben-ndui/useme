import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/dashboard/dashboard_exports.dart';

/// Stats grid for studio dashboard
class StudioStatsGrid extends StatelessWidget {
  final AppLocalizations l10n;

  const StudioStatsGrid({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionTitle(title: l10n.overview),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: BlocBuilder<SessionBloc, SessionState>(
                builder: (context, state) {
                  final today = state.sessions
                      .where((s) => s.isOnDate(DateTime.now()))
                      .length;
                  return DashboardStatCard(
                    label: l10n.today,
                    value: today.toString(),
                    icon: FontAwesomeIcons.calendar,
                    color: const Color(0xFF3B82F6),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BlocBuilder<SessionBloc, SessionState>(
                builder: (context, state) {
                  final pending = state.sessions
                      .where((s) => s.status == SessionStatus.pending)
                      .length;
                  return DashboardStatCard(
                    label: l10n.pendingStatus,
                    value: pending.toString(),
                    icon: FontAwesomeIcons.hourglass,
                    color: const Color(0xFFF59E0B),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: BlocBuilder<ArtistBloc, ArtistState>(
                builder: (context, state) {
                  return DashboardStatCard(
                    label: l10n.artists,
                    value: state.artists.length.toString(),
                    icon: FontAwesomeIcons.users,
                    color: const Color(0xFF8B5CF6),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BlocBuilder<SessionBloc, SessionState>(
                builder: (context, state) {
                  final now = DateTime.now();
                  final month = state.sessions
                      .where((s) =>
                          s.scheduledStart.year == now.year &&
                          s.scheduledStart.month == now.month)
                      .length;
                  return DashboardStatCard(
                    label: l10n.thisMonth,
                    value: month.toString(),
                    icon: FontAwesomeIcons.chartSimple,
                    color: const Color(0xFF10B981),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
