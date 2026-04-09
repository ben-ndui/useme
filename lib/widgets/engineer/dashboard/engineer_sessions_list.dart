import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/engineer/dashboard/engineer_session_tile.dart';

/// Sessions list for engineer dashboard (title + today + upcoming)
class EngineerSessionsList extends StatelessWidget {
  final AppLocalizations l10n;
  final String locale;

  const EngineerSessionsList({super.key, required this.l10n, required this.locale});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final padding = context.horizontalPadding;

    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Padding(
            padding: const EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface)),
          );
        }

        final todaySessions = _getTodaySessions(state.sessions);
        final upcomingSessions = _getUpcomingSessions(state.sessions).take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleRow(colorScheme, padding, todaySessions.length),
            if (todaySessions.isEmpty && upcomingSessions.isEmpty)
              _buildEmptyState(colorScheme)
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  children: [
                    for (final s in todaySessions)
                      EngineerSessionTile(session: s, locale: locale),
                    if (todaySessions.isEmpty) _buildNoSessionsToday(colorScheme),
                    if (upcomingSessions.isNotEmpty) ...[
                      _buildUpcomingHeader(upcomingSessions.length),
                      for (final s in upcomingSessions)
                        EngineerSessionTile(session: s, showDate: true, locale: locale),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTitleRow(ColorScheme colorScheme, double padding, int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.todaySessions,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Session> _getTodaySessions(List<Session> sessions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return sessions.where((s) {
      final start = s.scheduledStart;
      return start.isAfter(today.subtract(const Duration(seconds: 1))) && start.isBefore(tomorrow);
    }).toList()
      ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
  }

  List<Session> _getUpcomingSessions(List<Session> sessions) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    return sessions.where((s) => s.scheduledStart.isAfter(tomorrow)).toList()
      ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
  }

  Widget _buildUpcomingHeader(int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.upcomingStatus,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.orange)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('$count',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.orange)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSessionsToday(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
            child: FaIcon(FontAwesomeIcons.mugHot, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.noSessionToday,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text(l10n.enjoyYourDay, style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
            child: FaIcon(FontAwesomeIcons.calendarXmark, size: 36, color: colorScheme.primary),
          ),
          const SizedBox(height: 20),
          Text(l10n.noSessionsPlanned,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
          const SizedBox(height: 6),
          Text(l10n.noAssignedSessions, style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
