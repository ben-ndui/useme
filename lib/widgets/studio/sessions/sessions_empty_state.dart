import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/routing/app_routes.dart';

/// Empty state shown when no sessions or unavailabilities exist for a day
class SessionsEmptyDay extends StatelessWidget {
  final DateTime selectedDay;

  const SessionsEmptyDay({super.key, required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isToday = isSameDay(selectedDay, DateTime.now());

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              isToday ? l10n.freeDay : l10n.noSessions,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isToday
                  ? l10n.noSessionTodayScheduled
                  : l10n.noSessionThisDay,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: () => context.push(AppRoutes.sessionAdd),
              child: Text(l10n.scheduleSession),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state shown in list view tabs when no sessions exist
class SessionsEmptyTab extends StatelessWidget {
  const SessionsEmptyTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
}
