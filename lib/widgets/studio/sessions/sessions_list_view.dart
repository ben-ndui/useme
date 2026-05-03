import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uzme/core/blocs/blocs_exports.dart';
import 'package:uzme/core/models/models_exports.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/widgets/common/app_loader.dart';
import 'package:uzme/widgets/studio/sessions/session_card.dart';
import 'package:uzme/widgets/studio/sessions/sessions_empty_state.dart';
import 'package:uzme/widgets/studio/sessions/sessions_filter_sheet.dart';

/// List view with tabs for upcoming, in-progress, and past sessions
class SessionsListView extends StatelessWidget {
  final TabController tabController;
  final SessionFilters filters;
  final String locale;

  const SessionsListView({
    super.key,
    required this.tabController,
    required this.filters,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        if (state.isLoading) return const AppLoader.compact();

        final now = DateTime.now();
        final sessions = _applyFilters(state.sessions);

        final upcoming = sessions
            .where((s) =>
                s.scheduledStart.isAfter(now) &&
                s.displayStatus != SessionStatus.inProgress)
            .toList()
          ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));

        final inProgress = sessions
            .where((s) => s.displayStatus == SessionStatus.inProgress)
            .toList()
          ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));

        final past = sessions
            .where((s) =>
                s.scheduledStart.isBefore(now) &&
                s.displayStatus != SessionStatus.inProgress)
            .toList()
          ..sort((a, b) => b.scheduledStart.compareTo(a.scheduledStart));

        return TabBarView(
          controller: tabController,
          children: [
            _SessionListTab(
              sessions: upcoming,
              tabName: l10n.upcoming,
              locale: locale,
            ),
            _SessionListTab(
              sessions: inProgress,
              tabName: l10n.inProgress,
              locale: locale,
            ),
            _SessionListTab(
              sessions: past,
              tabName: l10n.past,
              locale: locale,
            ),
          ],
        );
      },
    );
  }

  List<Session> _applyFilters(List<Session> sessions) {
    if (!filters.hasFilters) return sessions;
    return sessions.where((s) {
      if (filters.status != null && s.displayStatus != filters.status) {
        return false;
      }
      if (filters.startDate != null &&
          s.scheduledStart.isBefore(filters.startDate!)) {
        return false;
      }
      if (filters.endDate != null &&
          s.scheduledStart
              .isAfter(filters.endDate!.add(const Duration(days: 1)))) {
        return false;
      }
      return true;
    }).toList();
  }
}

class _SessionListTab extends StatelessWidget {
  final List<Session> sessions;
  final String tabName;
  final String locale;

  const _SessionListTab({
    required this.sessions,
    required this.tabName,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (sessions.isEmpty) {
      return const SessionsEmptyTab();
    }

    final grouped = <DateTime, List<Session>>{};
    for (final session in sessions) {
      final date = DateTime(
        session.scheduledStart.year,
        session.scheduledStart.month,
        session.scheduledStart.day,
      );
      grouped.putIfAbsent(date, () => []).add(session);
    }

    final sortedDates = grouped.keys.toList()
      ..sort((a, b) => tabName == l10n.past
          ? b.compareTo(a)
          : a.compareTo(b));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final daySessions = grouped[date]!;
        final isToday = isSameDay(date, DateTime.now());
        final dateLabel = isToday
            ? l10n.today
            : DateFormat('EEEE d MMMM', locale).format(date);

        final theme = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      dateLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isToday ? theme.colorScheme.primary : null,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${daySessions.length}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...daySessions.map(
              (session) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SessionCard(session: session, locale: locale),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
