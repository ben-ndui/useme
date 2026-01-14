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

class _SessionsPageState extends State<SessionsPage>
    with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  SessionStatus? _selectedStatus;
  bool _isListView = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
            icon: FaIcon(
              _isListView ? FontAwesomeIcons.calendar : FontAwesomeIcons.list,
              size: 16,
            ),
            onPressed: () => setState(() => _isListView = !_isListView),
            tooltip: _isListView ? l10n.calendarView : l10n.listView,
          ),
          if (!_isListView)
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.filter, size: 16),
              onPressed: () => _showFilterSheet(context),
            ),
        ],
        bottom: _isListView
            ? TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: l10n.upcoming),
                  Tab(text: l10n.inProgress),
                  Tab(text: l10n.past),
                ],
              )
            : null,
      ),
      body: _isListView
          ? _buildListView(context, l10n, locale)
          : Column(
              children: [
                _buildCalendar(context, locale),
                Container(
                  height: 1,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                Expanded(child: _buildSessionsList(context, l10n, locale)),
              ],
            ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 88 + MediaQuery.of(context).viewPadding.bottom),
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
      builder: (context, sessionState) {
        return BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, calendarState) {
            final unavailabilities = calendarState is CalendarConnectedState
                ? calendarState.unavailabilities
                : <Unavailability>[];

            return TableCalendar<dynamic>(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              locale: locale,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) => [
                ..._getSessionsForDay(sessionState.sessions, day),
                ..._getUnavailabilitiesForDay(unavailabilities, day),
              ],
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
                markersMaxCount: 4,
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
                      children: events.take(4).map((event) {
                        final color = event is Session
                            ? getSessionStatusColor(event.displayStatus)
                            : theme.colorScheme.outline; // Gris pour indispos
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
                },
              ),
            );
          },
        );
      },
    );
  }

  List<Unavailability> _getUnavailabilitiesForDay(
    List<Unavailability> unavailabilities,
    DateTime day,
  ) {
    return unavailabilities.where((u) {
      // Check if the unavailability spans this day
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      return u.overlapsWith(dayStart, dayEnd);
    }).toList();
  }

  Widget _buildSessionsList(BuildContext context, AppLocalizations l10n, String locale) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, sessionState) {
        return BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, calendarState) {
            if (sessionState.isLoading) return const AppLoader.compact();

            var sessions = _getSessionsForDay(sessionState.sessions, _selectedDay);
            if (_selectedStatus != null) {
              sessions = sessions.where((s) => s.status == _selectedStatus).toList();
            }
            sessions.sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));

            final unavailabilities = calendarState is CalendarConnectedState
                ? _getUnavailabilitiesForDay(calendarState.unavailabilities, _selectedDay)
                : <Unavailability>[];
            unavailabilities.sort((a, b) => a.start.compareTo(b.start));

            if (sessions.isEmpty && unavailabilities.isEmpty) {
              return _buildEmptyDayState(context, l10n);
            }

            final totalCount = sessions.length + unavailabilities.length;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: totalCount + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildDayHeader(
                    context,
                    sessions.length,
                    l10n,
                    locale,
                    unavailCount: unavailabilities.length,
                  );
                }

                // Show unavailabilities first, then sessions
                final unavailIndex = index - 1;
                if (unavailIndex < unavailabilities.length) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _UnavailabilityCard(
                      unavailability: unavailabilities[unavailIndex],
                      locale: locale,
                    ),
                  );
                }

                final sessionIndex = unavailIndex - unavailabilities.length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SessionCard(session: sessions[sessionIndex], locale: locale),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDayHeader(
    BuildContext context,
    int count,
    AppLocalizations l10n,
    String locale, {
    int unavailCount = 0,
  }) {
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
                  FaIcon(
                    FontAwesomeIcons.ban,
                    size: 10,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$unavailCount',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
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

  Widget _buildListView(
    BuildContext context,
    AppLocalizations l10n,
    String locale,
  ) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        if (state.isLoading) return const AppLoader.compact();

        final now = DateTime.now();
        final sessions = state.sessions;

        // Séparer par catégorie
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
          controller: _tabController,
          children: [
            _buildSessionListTab(context, l10n, locale, upcoming, l10n.upcoming),
            _buildSessionListTab(context, l10n, locale, inProgress, l10n.inProgress),
            _buildSessionListTab(context, l10n, locale, past, l10n.past),
          ],
        );
      },
    );
  }

  Widget _buildSessionListTab(
    BuildContext context,
    AppLocalizations l10n,
    String locale,
    List<Session> sessions,
    String tabName,
  ) {
    final theme = Theme.of(context);

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: FaIcon(
                FontAwesomeIcons.calendarCheck,
                size: 28,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noSessions,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Grouper par date
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
          ? b.compareTo(a) // Passé: plus récent d'abord
          : a.compareTo(b)); // À venir: plus proche d'abord

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
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

/// Card to display an unavailability in the sessions list
class _UnavailabilityCard extends StatelessWidget {
  final Unavailability unavailability;
  final String locale;

  const _UnavailabilityCard({
    required this.unavailability,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm', locale);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.ban,
                  size: 16,
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unavailability.title ?? AppLocalizations.of(context)!.unavailable,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.clock,
                        size: 10,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${timeFormat.format(unavailability.start)} - ${timeFormat.format(unavailability.end)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          unavailability.source.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
