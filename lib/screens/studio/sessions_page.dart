import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/routing/app_routes.dart';

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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Sessions'),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.filter, size: 16),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          _buildCalendar(context),

          // Divider
          Container(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),

          // Sessions for selected day
          Expanded(child: _buildSessionsList(context)),
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

  Widget _buildCalendar(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        return TableCalendar<Session>(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          locale: 'fr_FR',
          startingDayOfWeek: StartingDayOfWeek.monday,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: (day) => _getSessionsForDay(state.sessions, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() => _calendarFormat = format);
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
            // Today
            todayDecoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),

            // Selected
            selectedDecoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),

            // Markers
            markerDecoration: BoxDecoration(
              color: theme.colorScheme.tertiary,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
            markerSize: 6,
            markerMargin: const EdgeInsets.symmetric(horizontal: 1),

            // Weekend
            weekendTextStyle: TextStyle(color: theme.colorScheme.error),

            // Outside days
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
            formatButtonTextStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
            titleTextStyle: theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
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
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: theme.textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.outline,
            ),
            weekendStyle: theme.textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.error.withValues(alpha: 0.7),
            ),
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
                        color: _getStatusColor(session.status),
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

  Widget _buildSessionsList(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        var sessions = _getSessionsForDay(state.sessions, _selectedDay);

        // Apply status filter
        if (_selectedStatus != null) {
          sessions = sessions.where((s) => s.status == _selectedStatus).toList();
        }

        // Sort by time
        sessions.sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));

        if (sessions.isEmpty) {
          return _buildEmptyDayState(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length + 1, // +1 for header
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildDayHeader(context, sessions.length);
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SessionCard(session: sessions[index - 1]),
            );
          },
        );
      },
    );
  }

  Widget _buildDayHeader(BuildContext context, int count) {
    final theme = Theme.of(context);
    final isToday = isSameDay(_selectedDay, DateTime.now());
    final dateLabel = isToday
        ? 'Aujourd\'hui'
        : DateFormat('EEEE d MMMM', 'fr_FR').format(_selectedDay);

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
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count session${count > 1 ? 's' : ''}',
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

  Widget _buildEmptyDayState(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = isSameDay(_selectedDay, DateTime.now());

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
            isToday ? 'Journée libre' : 'Aucune session',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isToday
                ? 'Aucune session programmée aujourd\'hui'
                : 'Pas de session ce jour',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.tonal(
            onPressed: () => context.push(AppRoutes.sessionAdd),
            child: const Text('Planifier une session'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterSheet(
        selectedStatus: _selectedStatus,
        onStatusSelected: (status) {
          setState(() => _selectedStatus = status);
          Navigator.pop(context);
        },
      ),
    );
  }

  List<Session> _getSessionsForDay(List<Session> sessions, DateTime day) {
    return sessions.where((s) => isSameDay(s.scheduledStart, day)).toList();
  }

  Color _getStatusColor(SessionStatus status) {
    return switch (status) {
      SessionStatus.pending => Colors.orange,
      SessionStatus.confirmed => Colors.blue,
      SessionStatus.inProgress => Colors.green,
      SessionStatus.completed => Colors.grey,
      SessionStatus.cancelled => Colors.red,
      SessionStatus.noShow => Colors.red,
    };
  }
}

// =============================================================================
// SESSION CARD
// =============================================================================

class _SessionCard extends StatelessWidget {
  final Session session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm', 'fr_FR');

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.push('/sessions/${session.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Time column
              SizedBox(
                width: 50,
                child: Column(
                  children: [
                    Text(
                      timeFormat.format(session.scheduledStart),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      timeFormat.format(session.scheduledEnd),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),

              // Color bar
              Container(
                width: 3,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _getTypeColor(session.type),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.artistName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        FaIcon(
                          _getTypeIcon(session.type),
                          size: 11,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          session.type.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status badge
              _StatusBadge(status: session.status),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(SessionType type) {
    return switch (type) {
      SessionType.recording => const Color(0xFF3B82F6),
      SessionType.mix || SessionType.mixing => const Color(0xFF8B5CF6),
      SessionType.mastering => const Color(0xFFF59E0B),
      SessionType.editing => const Color(0xFF10B981),
      _ => const Color(0xFF6B7280),
    };
  }

  IconData _getTypeIcon(SessionType type) {
    return switch (type) {
      SessionType.recording => FontAwesomeIcons.microphone,
      SessionType.mix || SessionType.mixing => FontAwesomeIcons.sliders,
      SessionType.mastering => FontAwesomeIcons.compactDisc,
      SessionType.editing => FontAwesomeIcons.scissors,
      _ => FontAwesomeIcons.music,
    };
  }
}

// =============================================================================
// STATUS BADGE
// =============================================================================

class _StatusBadge extends StatelessWidget {
  final SessionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      SessionStatus.pending => (Colors.orange, 'Attente'),
      SessionStatus.confirmed => (Colors.blue, 'Confirmé'),
      SessionStatus.inProgress => (Colors.green, 'En cours'),
      SessionStatus.completed => (Colors.grey, 'Terminé'),
      SessionStatus.cancelled => (Colors.red, 'Annulé'),
      SessionStatus.noShow => (Colors.red, 'Absent'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// =============================================================================
// FILTER SHEET
// =============================================================================

class _FilterSheet extends StatelessWidget {
  final SessionStatus? selectedStatus;
  final ValueChanged<SessionStatus?> onStatusSelected;

  const _FilterSheet({required this.selectedStatus, required this.onStatusSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Filtrer par statut',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: 'Tous',
                  isSelected: selectedStatus == null,
                  onTap: () => onStatusSelected(null),
                ),
                _FilterChip(
                  label: 'En attente',
                  color: Colors.orange,
                  isSelected: selectedStatus == SessionStatus.pending,
                  onTap: () => onStatusSelected(SessionStatus.pending),
                ),
                _FilterChip(
                  label: 'Confirmées',
                  color: Colors.blue,
                  isSelected: selectedStatus == SessionStatus.confirmed,
                  onTap: () => onStatusSelected(SessionStatus.confirmed),
                ),
                _FilterChip(
                  label: 'En cours',
                  color: Colors.green,
                  isSelected: selectedStatus == SessionStatus.inProgress,
                  onTap: () => onStatusSelected(SessionStatus.inProgress),
                ),
                _FilterChip(
                  label: 'Terminées',
                  color: Colors.grey,
                  isSelected: selectedStatus == SessionStatus.completed,
                  onTap: () => onStatusSelected(SessionStatus.completed),
                ),
                _FilterChip(
                  label: 'Annulées',
                  color: Colors.red,
                  isSelected: selectedStatus == SessionStatus.cancelled,
                  onTap: () => onStatusSelected(SessionStatus.cancelled),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return Material(
      color: isSelected ? chipColor : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
