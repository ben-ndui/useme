import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/config/useme_theme.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/widgets/artist/sessions/artist_sessions_exports.dart';
import 'package:useme/widgets/artist/sessions/artist_session_filter_sheet.dart';
import 'package:useme/widgets/artist/sessions/artist_month_calendar.dart';
import 'package:useme/widgets/artist/studio_selector_bottom_sheet.dart';

/// View mode for artist sessions page
enum _ViewMode { week, month, list }

/// Artist sessions page - Calendar view with week selector
class ArtistSessionsPage extends StatefulWidget {
  const ArtistSessionsPage({super.key});

  @override
  State<ArtistSessionsPage> createState() => _ArtistSessionsPageState();
}

class _ArtistSessionsPageState extends State<ArtistSessionsPage> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _weekStart;
  late DateTime _displayedMonth;
  _ViewMode _viewMode = _ViewMode.week;
  ArtistSessionFilters _filters = ArtistSessionFilters.empty;

  @override
  void initState() {
    super.initState();
    _weekStart = _getWeekStart(_selectedDate);
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  DateTime _getWeekStart(DateTime date) => date.subtract(Duration(days: date.weekday - 1));
  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context, l10n, colorScheme),
      body: switch (_viewMode) {
        _ViewMode.list => _buildAllSessionsList(colorScheme, l10n),
        _ViewMode.month => _buildMonthView(colorScheme, l10n),
        _ViewMode.week => Column(
            children: [
              _buildWeekCalendar(colorScheme),
              Expanded(child: _buildSessionsList(colorScheme, l10n)),
            ],
          ),
      },
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 100 + MediaQuery.of(context).viewPadding.bottom),
        child: FloatingActionButton.extended(
          onPressed: () => StudioSelectorBottomSheet.showAndNavigate(context),
          icon: const FaIcon(FontAwesomeIcons.calendarPlus, size: 18),
          label: Text(l10n.book),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  AppBar _buildAppBar(BuildContext context, AppLocalizations l10n, ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Text(l10n.mySessions, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
      centerTitle: true,
      actions: [
        _buildFilterButton(context, colorScheme),
        const SizedBox(width: 4),
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

  Widget _buildFilterButton(BuildContext context, ColorScheme colorScheme) {
    final hasFilters = _filters.hasFilters;

    return Stack(
      children: [
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.filter,
            size: 18,
            color: hasFilters ? UseMeTheme.primaryColor : colorScheme.onSurfaceVariant,
          ),
          onPressed: () => ArtistSessionFilterSheet.show(
            context,
            currentFilters: _filters,
            onApply: (filters) => setState(() => _filters = filters),
          ),
        ),
        if (hasFilters)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: UseMeTheme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildViewToggle(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(colorScheme, FontAwesomeIcons.calendarWeek, _viewMode == _ViewMode.week, () => setState(() => _viewMode = _ViewMode.week)),
          _buildToggleButton(colorScheme, FontAwesomeIcons.calendarDays, _viewMode == _ViewMode.month, () => setState(() => _viewMode = _ViewMode.month)),
          _buildToggleButton(colorScheme, FontAwesomeIcons.list, _viewMode == _ViewMode.list, () => setState(() => _viewMode = _ViewMode.list)),
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
    final locale = Localizations.localeOf(context).languageCode;
    final monthFormat = DateFormat('MMMM yyyy', locale);

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

  Widget _buildMonthView(ColorScheme colorScheme, AppLocalizations l10n) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        final sessions = _applyFilters(state.sessions);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
              child: ArtistMonthCalendar(
                selectedDate: _selectedDate,
                displayedMonth: _displayedMonth,
                sessions: sessions,
                onDateSelected: (date) => setState(() {
                  _selectedDate = date;
                  _displayedMonth = DateTime(date.year, date.month);
                }),
                onPreviousMonth: () => setState(() {
                  _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
                }),
                onNextMonth: () => setState(() {
                  _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
                }),
              ),
            ),
            Expanded(child: _buildSessionsList(colorScheme, l10n)),
          ],
        );
      },
    );
  }

  Widget _buildDayCell(ColorScheme colorScheme, DateTime day) {
    final locale = Localizations.localeOf(context).languageCode;
    final dayFormat = DateFormat('E', locale);
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

  Widget _buildSessionsList(ColorScheme colorScheme, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat('EEEE d MMMM', locale);

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
            child: Text(dateFormat.format(_selectedDate), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
          ),
          Expanded(
            child: BlocBuilder<SessionBloc, SessionState>(
              builder: (context, state) {
                if (state.isLoading) return const AppLoader.compact();

                final daySessions = _getSessionsForDay(state.sessions, _selectedDate);

                if (daySessions.isEmpty) return _buildEmptyDay(colorScheme, l10n);

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: daySessions.length,
                  itemBuilder: (context, index) => ArtistSessionTile(
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

  List<Session> _applyFilters(List<Session> sessions) {
    if (!_filters.hasFilters) return sessions;
    return sessions.where((s) {
      if (_filters.statuses.isNotEmpty && !_filters.statuses.contains(s.displayStatus)) return false;
      return true;
    }).toList();
  }

  List<Session> _getSessionsForDay(List<Session> sessions, DateTime day) {
    final filtered = _applyFilters(sessions);
    return filtered.where((s) => _isSameDay(s.scheduledStart, day)).toList()
      ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
  }

  Widget _buildEmptyDay(ColorScheme colorScheme, AppLocalizations l10n) {
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
          Text(l10n.noSession, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
          const SizedBox(height: 6),
          Text(l10n.enjoyYourDay, style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildAllSessionsList(ColorScheme colorScheme, AppLocalizations l10n) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        if (state.isLoading) return const AppLoader.compact();

        final allSessions = state.sessions.where((s) => s.status != SessionStatus.cancelled).toList();
        final sessions = _applyFilters(allSessions);
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

        if (sessions.isEmpty) return _buildEmptyList(colorScheme, l10n);

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
                  _buildSectionHeader(colorScheme, l10n.inProgressStatus, Colors.blue, inProgress.length),
                  ...inProgress.map((s) => ArtistSessionListTile(session: s, isPast: false, onTap: () => context.push('/artist/sessions/${s.id}'))),
                  const SizedBox(height: 24),
                ],
                if (upcoming.isNotEmpty) ...[
                  _buildSectionHeader(colorScheme, l10n.upcomingStatus, Colors.orange, upcoming.length),
                  ...upcoming.map((s) => ArtistSessionListTile(session: s, isPast: false, onTap: () => context.push('/artist/sessions/${s.id}'))),
                  const SizedBox(height: 24),
                ],
                if (past.isNotEmpty) ...[
                  _buildSectionHeader(colorScheme, l10n.pastStatus, Colors.grey, past.length),
                  ...past.take(15).map((s) => ArtistSessionListTile(session: s, isPast: true, onTap: () => context.push('/artist/sessions/${s.id}'))),
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

  Widget _buildEmptyList(ColorScheme colorScheme, AppLocalizations l10n) {
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
          Text(l10n.noSessions, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
          const SizedBox(height: 6),
          Text(l10n.bookFirstSession, style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
