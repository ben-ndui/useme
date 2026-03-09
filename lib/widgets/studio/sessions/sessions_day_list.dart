import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/widgets/studio/sessions/session_card.dart';
import 'package:useme/widgets/studio/sessions/sessions_empty_state.dart';
import 'package:useme/widgets/studio/sessions/sessions_filter_sheet.dart';
import 'package:useme/widgets/studio/sessions/unavailability_card.dart';

/// Calendar day-sessions list (shown below the calendar)
class SessionsDayList extends StatelessWidget {
  final DateTime selectedDay;
  final SessionFilters filters;
  final String locale;

  const SessionsDayList({
    super.key,
    required this.selectedDay,
    required this.filters,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, sessionState) {
        return BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, calendarState) {
            if (sessionState.isLoading) return const AppLoader.compact();

            var sessions = _getSessionsForDay(
              sessionState.sessions,
              selectedDay,
            );
            if (filters.status != null) {
              sessions = sessions
                  .where((s) => s.status == filters.status)
                  .toList();
            }
            sessions.sort(
              (a, b) => a.scheduledStart.compareTo(b.scheduledStart),
            );

            final unavailabilities =
                calendarState is CalendarConnectedState
                    ? _getUnavailabilitiesForDay(
                        calendarState.unavailabilities,
                        selectedDay,
                      )
                    : <Unavailability>[];
            unavailabilities.sort((a, b) => a.start.compareTo(b.start));

            if (sessions.isEmpty && unavailabilities.isEmpty) {
              return SessionsEmptyDay(selectedDay: selectedDay);
            }

            final totalCount = sessions.length + unavailabilities.length;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: totalCount + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _DayHeader(
                    selectedDay: selectedDay,
                    sessionCount: sessions.length,
                    unavailCount: unavailabilities.length,
                    locale: locale,
                  );
                }

                final unavailIndex = index - 1;
                if (unavailIndex < unavailabilities.length) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: UnavailabilityCard(
                      unavailability: unavailabilities[unavailIndex],
                      locale: locale,
                    ),
                  );
                }

                final sessionIndex =
                    unavailIndex - unavailabilities.length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SessionCard(
                    session: sessions[sessionIndex],
                    locale: locale,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  List<Session> _getSessionsForDay(List<Session> sessions, DateTime day) =>
      sessions.where((s) => isSameDay(s.scheduledStart, day)).toList();

  List<Unavailability> _getUnavailabilitiesForDay(
    List<Unavailability> unavailabilities, DateTime day,
  ) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return unavailabilities.where((u) => u.overlapsWith(dayStart, dayEnd)).toList();
  }
}

class _DayHeader extends StatelessWidget {
  final DateTime selectedDay;
  final int sessionCount;
  final int unavailCount;
  final String locale;

  const _DayHeader({
    required this.selectedDay,
    required this.sessionCount,
    required this.unavailCount,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isToday = isSameDay(selectedDay, DateTime.now());
    final dateLabel = isToday
        ? l10n.today
        : DateFormat('EEEE d MMMM', locale).format(selectedDay);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dateLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isToday ? theme.colorScheme.primary : null,
              ),
            ),
          ),
          if (unavailCount > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(FontAwesomeIcons.ban, size: 10, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    '$unavailCount',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600, color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              sessionCount > 1
                  ? l10n.sessionsCount(sessionCount)
                  : l10n.sessionCount(sessionCount),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
