import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/common/dashboard/dashboard_exports.dart';

/// Today's sessions timeline for studio dashboard
class StudioTodayTimeline extends StatelessWidget {
  final AppLocalizations l10n;
  final String locale;

  const StudioTodayTimeline({super.key, required this.l10n, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DashboardSectionTitle(title: l10n.todaySessions),
            DashboardViewAllChip(
              label: l10n.viewAll,
              onTap: () => context.push(AppRoutes.sessions),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<SessionBloc, SessionState>(
          builder: (context, state) {
            final today = DateTime.now();
            final todaySessions = state.sessions
                .where((s) => s.isOnDate(today))
                .toList()
              ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));

            if (todaySessions.isEmpty) {
              return DashboardEmptyCard(
                icon: FontAwesomeIcons.calendarCheck,
                title: l10n.freeDay,
                subtitle: l10n.noSessionScheduled,
              );
            }

            return Column(
              children: todaySessions.take(4).map((session) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TimelineSessionCard(
                    session: session,
                    l10n: l10n,
                    locale: locale,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _TimelineSessionCard extends StatelessWidget {
  final Session session;
  final AppLocalizations l10n;
  final String locale;

  const _TimelineSessionCard({
    required this.session,
    required this.l10n,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm', locale);
    final isNow = _isCurrentSession();

    return Material(
      color: isNow
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.push('/sessions/${session.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Column(
                  children: [
                    Text(
                      timeFormat.format(session.scheduledStart),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isNow ? theme.colorScheme.primary : null,
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
              Container(
                width: 3,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _getTypeColor(session.type),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
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
                          session.typeLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              DashboardStatusBadge(status: session.displayStatus, l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }

  bool _isCurrentSession() {
    final now = DateTime.now();
    return now.isAfter(session.scheduledStart) && now.isBefore(session.scheduledEnd);
  }

  Color _getTypeColor(SessionType type) {
    switch (type) {
      case SessionType.recording:
        return const Color(0xFF3B82F6);
      case SessionType.mix:
      case SessionType.mixing:
        return const Color(0xFF8B5CF6);
      case SessionType.mastering:
        return const Color(0xFFF59E0B);
      case SessionType.editing:
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getTypeIcon(SessionType type) {
    switch (type) {
      case SessionType.recording:
        return FontAwesomeIcons.microphone;
      case SessionType.mix:
      case SessionType.mixing:
        return FontAwesomeIcons.sliders;
      case SessionType.mastering:
        return FontAwesomeIcons.compactDisc;
      case SessionType.editing:
        return FontAwesomeIcons.scissors;
      default:
        return FontAwesomeIcons.music;
    }
  }
}
