import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uzme/core/blocs/blocs_exports.dart';
import 'package:uzme/core/models/models_exports.dart';
import 'package:uzme/widgets/studio/sessions/session_status_badge.dart';

/// Calendar widget for the sessions page
class SessionsCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final CalendarFormat calendarFormat;
  final String locale;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<CalendarFormat> onFormatChanged;
  final ValueChanged<DateTime> onPageChanged;

  const SessionsCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.locale,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, sessionState) {
        return BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, calendarState) {
            final unavailabilities =
                calendarState is CalendarConnectedState
                    ? calendarState.unavailabilities
                    : <Unavailability>[];

            return TableCalendar<dynamic>(
              firstDay:
                  DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: focusedDay,
              calendarFormat: calendarFormat,
              locale: locale,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) =>
                  isSameDay(selectedDay, day),
              eventLoader: (day) => [
                ..._getSessionsForDay(sessionState.sessions, day),
                ..._getUnavailabilitiesForDay(unavailabilities, day),
              ],
              onDaySelected: (selected, focused) =>
                  onDaySelected(selected),
              onFormatChanged: onFormatChanged,
              onPageChanged: onPageChanged,
              calendarStyle: _calendarStyle(theme),
              headerStyle: _headerStyle(theme),
              daysOfWeekStyle: _daysOfWeekStyle(theme),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return null;
                  return _buildMarkers(theme, events);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMarkers(ThemeData theme, List<dynamic> events) {
    return Positioned(
      bottom: 4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: events.take(4).map((event) {
          final color = event is Session
              ? getSessionStatusColor(event.displayStatus)
              : theme.colorScheme.outline;
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          );
        }).toList(),
      ),
    );
  }

  CalendarStyle _calendarStyle(ThemeData theme) {
    return CalendarStyle(
      todayDecoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      todayTextStyle: TextStyle(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
      selectedDecoration: BoxDecoration(
        color: theme.colorScheme.primary,
        shape: BoxShape.circle,
      ),
      selectedTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      markerDecoration: BoxDecoration(
        color: theme.colorScheme.tertiary,
        shape: BoxShape.circle,
      ),
      markersMaxCount: 4,
      markerSize: 6,
      markerMargin: const EdgeInsets.symmetric(horizontal: 1),
      weekendTextStyle: TextStyle(color: theme.colorScheme.error),
      outsideDaysVisible: false,
    );
  }

  HeaderStyle _headerStyle(ThemeData theme) {
    return HeaderStyle(
      formatButtonVisible: true,
      titleCentered: true,
      formatButtonShowsNext: false,
      formatButtonDecoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      formatButtonTextStyle: TextStyle(
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: 12,
      ),
      titleTextStyle: theme.textTheme.titleMedium!
          .copyWith(fontWeight: FontWeight.bold),
      leftChevronIcon: FaIcon(
        FontAwesomeIcons.chevronLeft,
        size: 14,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      rightChevronIcon: FaIcon(
        FontAwesomeIcons.chevronRight,
        size: 14,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  DaysOfWeekStyle _daysOfWeekStyle(ThemeData theme) {
    return DaysOfWeekStyle(
      weekdayStyle: theme.textTheme.bodySmall!.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.outline,
      ),
      weekendStyle: theme.textTheme.bodySmall!.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.error.withValues(alpha: 0.7),
      ),
    );
  }

  List<Session> _getSessionsForDay(
    List<Session> sessions,
    DateTime day,
  ) {
    return sessions
        .where((s) => isSameDay(s.scheduledStart, day))
        .toList();
  }

  List<Unavailability> _getUnavailabilitiesForDay(
    List<Unavailability> unavailabilities,
    DateTime day,
  ) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return unavailabilities
        .where((u) => u.overlapsWith(dayStart, dayEnd))
        .toList();
  }
}
