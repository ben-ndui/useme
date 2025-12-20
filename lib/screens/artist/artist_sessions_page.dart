import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';

/// Artist sessions page - Calendar view with week selector
class ArtistSessionsPage extends StatefulWidget {
  const ArtistSessionsPage({super.key});

  @override
  State<ArtistSessionsPage> createState() => _ArtistSessionsPageState();
}

class _ArtistSessionsPageState extends State<ArtistSessionsPage> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _weekStart;
  bool _isListView = false;

  @override
  void initState() {
    super.initState();
    _weekStart = _getWeekStart(_selectedDate);
  }

  DateTime _getWeekStart(DateTime date) => date.subtract(Duration(days: date.weekday - 1));
  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context),
      body: _isListView
          ? _buildAllSessionsList(colorScheme)
          : Column(
              children: [
                _buildWeekCalendar(colorScheme),
                Expanded(child: _buildSessionsList(colorScheme)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/artist/request'),
        icon: const FaIcon(FontAwesomeIcons.calendarPlus, size: 18),
        label: const Text('Réserver'),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Mes sessions',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: FaIcon(FontAwesomeIcons.bell, size: 18, color: colorScheme.onSurfaceVariant),
          onPressed: () => context.push('/notifications'),
        ),
        const SizedBox(width: 4),
        _buildViewToggle(colorScheme),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildViewToggle(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(colorScheme, FontAwesomeIcons.calendar, !_isListView, () => setState(() => _isListView = false)),
          _buildToggleButton(colorScheme, FontAwesomeIcons.list, _isListView, () => setState(() => _isListView = true)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(ColorScheme colorScheme, IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: FaIcon(icon, size: 14, color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildWeekCalendar(ColorScheme colorScheme) {
    final days = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
    final monthFormat = DateFormat('MMMM yyyy', 'fr_FR');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => setState(() {
                  _weekStart = _weekStart.subtract(const Duration(days: 7));
                  _selectedDate = _weekStart;
                }),
                icon: FaIcon(FontAwesomeIcons.chevronLeft, size: 14, color: colorScheme.onSurfaceVariant),
                style: IconButton.styleFrom(backgroundColor: colorScheme.surfaceContainerHighest),
              ),
              Text(
                monthFormat.format(_selectedDate).toUpperCase(),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, letterSpacing: 1),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _weekStart = _weekStart.add(const Duration(days: 7));
                  _selectedDate = _weekStart;
                }),
                icon: FaIcon(FontAwesomeIcons.chevronRight, size: 14, color: colorScheme.onSurfaceVariant),
                style: IconButton.styleFrom(backgroundColor: colorScheme.surfaceContainerHighest),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: days.map((day) => Expanded(child: _buildDayCell(colorScheme, day))).toList()),
        ],
      ),
    );
  }

  Widget _buildDayCell(ColorScheme colorScheme, DateTime day) {
    final dayFormat = DateFormat('E', 'fr_FR');
    final isSelected = _isSameDay(day, _selectedDate);
    final isToday = _isSameDay(day, DateTime.now());

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = day),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : (isToday ? colorScheme.primaryContainer.withValues(alpha: 0.5) : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayFormat.format(day).substring(0, 2).toUpperCase(),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            Text(
              '${day.day}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isSelected ? colorScheme.onPrimary : (isToday ? colorScheme.primary : colorScheme.onSurface)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsList(ColorScheme colorScheme) {
    final dateFormat = DateFormat('EEEE d MMMM', 'fr_FR');

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              dateFormat.format(_selectedDate),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
            ),
          ),
          Expanded(
            child: BlocBuilder<SessionBloc, SessionState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final daySessions = _getSessionsForDay(state.sessions, _selectedDate);

                if (daySessions.isEmpty) {
                  return _buildEmptyDay(colorScheme);
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: daySessions.length,
                  itemBuilder: (context, index) => _SessionTile(
                    session: daySessions[index],
                    onTap: () => context.push('/artist/sessions/${daySessions[index].id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Session> _getSessionsForDay(List<Session> sessions, DateTime day) {
    return sessions.where((s) => _isSameDay(s.scheduledStart, day)).toList()
      ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
  }

  Widget _buildEmptyDay(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: FaIcon(FontAwesomeIcons.mugHot, size: 32, color: colorScheme.primary),
          ),
          const SizedBox(height: 20),
          Text('Pas de session', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
          const SizedBox(height: 6),
          Text('Profitez de votre journée !', style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildAllSessionsList(ColorScheme colorScheme) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final sessions = state.sessions.where((s) => s.status != SessionStatus.cancelled).toList();
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final inProgress = sessions.where((s) => s.status == SessionStatus.inProgress).toList()
          ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
        final upcoming = sessions.where((s) =>
          (s.status == SessionStatus.pending || s.status == SessionStatus.confirmed) &&
          s.scheduledStart.isAfter(today.subtract(const Duration(days: 1)))
        ).toList()..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
        final past = sessions.where((s) =>
          s.status == SessionStatus.completed ||
          ((s.status == SessionStatus.pending || s.status == SessionStatus.confirmed) && s.scheduledStart.isBefore(today))
        ).toList()..sort((a, b) => b.scheduledStart.compareTo(a.scheduledStart));

        if (sessions.isEmpty) {
          return _buildEmptyList(colorScheme);
        }

        return RefreshIndicator(
          onRefresh: () async {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticatedState) {
              context.read<SessionBloc>().add(LoadArtistSessionsEvent(artistId: authState.user.uid));
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (inProgress.isNotEmpty) ...[
                  _buildSectionHeader(colorScheme, 'En cours', Colors.blue, inProgress.length),
                  ...inProgress.map((s) => _SessionListTile(session: s, isPast: false, onTap: () => context.push('/artist/sessions/${s.id}'))),
                  const SizedBox(height: 24),
                ],
                if (upcoming.isNotEmpty) ...[
                  _buildSectionHeader(colorScheme, 'À venir', Colors.orange, upcoming.length),
                  ...upcoming.map((s) => _SessionListTile(session: s, isPast: false, onTap: () => context.push('/artist/sessions/${s.id}'))),
                  const SizedBox(height: 24),
                ],
                if (past.isNotEmpty) ...[
                  _buildSectionHeader(colorScheme, 'Passées', Colors.grey, past.length),
                  ...past.take(15).map((s) => _SessionListTile(session: s, isPast: true, onTap: () => context.push('/artist/sessions/${s.id}'))),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(ColorScheme colorScheme, String title, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                  child: Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyList(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: colorScheme.primaryContainer.withValues(alpha: 0.5), shape: BoxShape.circle),
            child: FaIcon(FontAwesomeIcons.calendarXmark, size: 32, color: colorScheme.onPrimaryContainer.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 20),
          Text('Aucune session', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
          const SizedBox(height: 6),
          Text('Réservez votre première session', style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// Session tile for calendar view
class _SessionTile extends StatelessWidget {
  final Session session;
  final VoidCallback onTap;

  const _SessionTile({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeFormat = DateFormat('HH:mm', 'fr_FR');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: colorScheme.primaryContainer.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  Text(timeFormat.format(session.scheduledStart), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colorScheme.primary)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          session.type.label,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusBadge(colorScheme),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FaIcon(_getTypeIcon(session.type), size: 10, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${session.durationMinutes ~/ 60}h de session',
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ColorScheme colorScheme) {
    final (color, label) = _getStatusInfo();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }

  (Color, String) _getStatusInfo() {
    return switch (session.status) {
      SessionStatus.pending => (Colors.orange, 'En attente'),
      SessionStatus.confirmed => (Colors.green, 'Confirmée'),
      SessionStatus.inProgress => (Colors.blue, 'En cours'),
      SessionStatus.completed => (Colors.grey, 'Terminée'),
      SessionStatus.cancelled => (Colors.red, 'Annulée'),
      SessionStatus.noShow => (Colors.red, 'Absent'),
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

/// Session tile for list view
class _SessionListTile extends StatelessWidget {
  final Session session;
  final bool isPast;
  final VoidCallback onTap;

  const _SessionListTile({required this.session, required this.isPast, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('EEE d MMM', 'fr_FR');
    final timeFormat = DateFormat('HH:mm', 'fr_FR');

    return Opacity(
      opacity: isPast ? 0.6 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: _getStatusColor().withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: FaIcon(_getTypeIcon(session.type), size: 16, color: _getStatusColor()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.type.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        FaIcon(FontAwesomeIcons.calendar, size: 10, color: isPast ? colorScheme.onSurfaceVariant : colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${dateFormat.format(session.scheduledStart)} à ${timeFormat.format(session.scheduledStart)}',
                          style: TextStyle(fontSize: 12, color: isPast ? colorScheme.onSurfaceVariant : colorScheme.primary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isPast && session.status == SessionStatus.completed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                  child: const Text('Terminée', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.green)),
                )
              else
                FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (isPast) return Colors.grey;
    return switch (session.status) {
      SessionStatus.pending => Colors.orange,
      SessionStatus.confirmed => Colors.green,
      SessionStatus.inProgress => Colors.blue,
      SessionStatus.completed => Colors.grey,
      SessionStatus.cancelled || SessionStatus.noShow => Colors.red,
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
