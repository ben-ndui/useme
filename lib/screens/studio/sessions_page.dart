import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/widgets/studio/sessions/sessions_exports.dart';

/// Sessions page with calendar and list views
class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  SessionStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.sessionsLabel),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.filter, size: 16),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(context, locale),
          Container(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
          Expanded(child: _buildSessionsList(context, l10n, locale)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 88),
        child: FloatingActionButton(
          onPressed: () => context.push(AppRoutes.sessionAdd),
          child: const FaIcon(FontAwesomeIcons.plus, size: 18),
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, String locale) {
    final theme = Theme.of(context);

    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        return TableCalendar<Session>(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          locale: locale,
          startingDayOfWeek: StartingDayOfWeek.monday,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: (day) => _getSessionsForDay(state.sessions, day),
          onDaySelected: (selectedDay, focusedDay) => setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          }),
          onFormatChanged: (format) => setState(() => _calendarFormat = format),
          onPageChanged: (focusedDay) => _focusedDay = focusedDay,
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
            selectedDecoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
            selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            markerDecoration: BoxDecoration(color: theme.colorScheme.tertiary, shape: BoxShape.circle),
            markersMaxCount: 3,
            markerSize: 6,
            markerMargin: const EdgeInsets.symmetric(horizontal: 1),
            weekendTextStyle: TextStyle(color: theme.colorScheme.error),
            outsideDaysVisible: false,
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
            formatButtonDecoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            formatButtonTextStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
            titleTextStyle: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            leftChevronIcon: FaIcon(FontAwesomeIcons.chevronLeft, size: 14, color: theme.colorScheme.onSurfaceVariant),
            rightChevronIcon: FaIcon(FontAwesomeIcons.chevronRight, size: 14, color: theme.colorScheme.onSurfaceVariant),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: theme.textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.outline),
            weekendStyle: theme.textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.error.withValues(alpha: 0.7)),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return null;
              return Positioned(
                bottom: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: events.take(3).map((session) {
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: getSessionStatusColor(session.displayStatus),
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSessionsList(BuildContext context, AppLocalizations l10n, String locale) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        if (state.isLoading) return const AppLoader.compact();

        var sessions = _getSessionsForDay(state.sessions, _selectedDay);
        if (_selectedStatus != null) {
          sessions = sessions.where((s) => s.status == _selectedStatus).toList();
        }
        sessions.sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));

        if (sessions.isEmpty) return _buildEmptyDayState(context, l10n);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _buildDayHeader(context, sessions.length, l10n, locale);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SessionCard(session: sessions[index - 1], locale: locale),
            );
          },
        );
      },
    );
  }

  Widget _buildDayHeader(BuildContext context, int count, AppLocalizations l10n, String locale) {
    final theme = Theme.of(context);
    final isToday = isSameDay(_selectedDay, DateTime.now());
    final dateLabel = isToday ? l10n.today : DateFormat('EEEE d MMMM', locale).format(_selectedDay);

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
            child: Text(
              count > 1 ? l10n.sessionsCount(count) : l10n.sessionCount(count),
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDayState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isToday = isSameDay(_selectedDay, DateTime.now());

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, shape: BoxShape.circle),
            child: FaIcon(FontAwesomeIcons.calendarCheck, size: 28, color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 16),
          Text(isToday ? l10n.freeDay : l10n.noSessions, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            isToday ? l10n.noSessionTodayScheduled : l10n.noSessionThisDay,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 20),
          FilledButton.tonal(onPressed: () => context.push(AppRoutes.sessionAdd), child: Text(l10n.scheduleSession)),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SessionsFilterSheet(
        selectedStatus: _selectedStatus,
        onStatusSelected: (status) {
          setState(() => _selectedStatus = status);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  List<Session> _getSessionsForDay(List<Session> sessions, DateTime day) {
    return sessions.where((s) => isSameDay(s.scheduledStart, day)).toList();
  }
}
