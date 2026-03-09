import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/core/localization/intl_locale.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
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
  SessionFilters _filters = SessionFilters.empty;
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
    final locale = intlLocale(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme, l10n),
      body: _isListView
          ? SessionsListView(
              tabController: _tabController,
              filters: _filters,
              locale: locale,
            )
          : Column(
              children: [
                SessionsCalendar(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  calendarFormat: _calendarFormat,
                  locale: locale,
                  onDaySelected: (day) => setState(() {
                    _selectedDay = day;
                    _focusedDay = day;
                  }),
                  onFormatChanged: (format) =>
                      setState(() => _calendarFormat = format),
                  onPageChanged: (day) => _focusedDay = day,
                ),
                Container(
                  height: 1,
                  color: theme.colorScheme.outlineVariant
                      .withValues(alpha: 0.3),
                ),
                Expanded(
                  child: SessionsDayList(
                    selectedDay: _selectedDay,
                    filters: _filters,
                    locale: locale,
                  ),
                ),
              ],
            ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: Responsive.fabBottomOffset +
              MediaQuery.of(context).viewPadding.bottom,
        ),
        child: FloatingActionButton(
          onPressed: () => context.push(AppRoutes.sessionAdd),
          child: const FaIcon(FontAwesomeIcons.plus, size: 18),
        ),
      ),
    );
  }

  AppBar _buildAppBar(ThemeData theme, AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n.sessionsLabel),
      backgroundColor: theme.colorScheme.surface,
      actions: [
        IconButton(
          icon: FaIcon(
            _isListView
                ? FontAwesomeIcons.calendar
                : FontAwesomeIcons.list,
            size: 16,
          ),
          onPressed: () => setState(() => _isListView = !_isListView),
          tooltip: _isListView ? l10n.calendarView : l10n.listView,
        ),
        Stack(
          children: [
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.filter,
                size: 16,
                color: _filters.hasFilters
                    ? theme.colorScheme.primary
                    : null,
              ),
              onPressed: () => _showFilterSheet(context),
            ),
            if (_filters.hasFilters)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
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
    );
  }

  void _showFilterSheet(BuildContext context) {
    SessionsFilterSheet.show(
      context,
      currentFilters: _filters,
      onFiltersChanged: (filters) => setState(() => _filters = filters),
    );
  }
}
