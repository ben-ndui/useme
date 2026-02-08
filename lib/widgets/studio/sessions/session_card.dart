import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:useme/core/models/session.dart';
import 'package:useme/widgets/studio/sessions/session_status_badge.dart';

/// Session card for the sessions list
class SessionCard extends StatelessWidget {
  final Session session;
  final String locale;

  const SessionCard({super.key, required this.session, required this.locale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm', locale);

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
              _buildTimeColumn(theme, timeFormat),
              _buildColorBar(theme),
              _buildInfo(theme),
              SessionStatusBadge(status: session.displayStatus),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeColumn(ThemeData theme, DateFormat timeFormat) {
    return SizedBox(
      width: 50,
      child: Column(
        children: [
          Text(
            timeFormat.format(session.scheduledStart),
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            timeFormat.format(session.scheduledEnd),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildColorBar(ThemeData theme) {
    return Container(
      width: 3,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _getTypeColor(session.types.firstOrNull ?? SessionType.other),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildInfo(ThemeData theme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session.artistName,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              FaIcon(_getTypeIcon(session.types.firstOrNull ?? SessionType.other), size: 11, color: theme.colorScheme.outline),
              const SizedBox(width: 6),
              Text(
                session.typeLabel,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ),
        ],
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
