import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/dashboard/dashboard_exports.dart';

/// Stats row for engineer dashboard
class EngineerStatsRow extends StatelessWidget {
  final AppLocalizations l10n;

  const EngineerStatsRow({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        final todayCount = _getTodaySessions(state.sessions).length;
        final upcomingCount = _getUpcomingSessions(state.sessions).length;
        final inProgressCount = state.sessions
            .where((s) => s.status == SessionStatus.inProgress)
            .length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: DashboardStatCard(
                  label: l10n.today,
                  value: '$todayCount',
                  icon: FontAwesomeIcons.calendarDay,
                  color: Colors.blue,
                  compact: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DashboardStatCard(
                  label: l10n.upcomingStatus,
                  value: '$upcomingCount',
                  icon: FontAwesomeIcons.calendarWeek,
                  color: Colors.orange,
                  compact: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DashboardStatCard(
                  label: l10n.inProgressStatus,
                  value: '$inProgressCount',
                  icon: FontAwesomeIcons.play,
                  color: Colors.green,
                  compact: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Session> _getTodaySessions(List<Session> sessions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return sessions.where((s) {
      final start = s.scheduledStart;
      return start.isAfter(today.subtract(const Duration(seconds: 1))) &&
          start.isBefore(tomorrow);
    }).toList();
  }

  List<Session> _getUpcomingSessions(List<Session> sessions) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

    return sessions.where((s) => s.scheduledStart.isAfter(tomorrow)).toList();
  }
}
