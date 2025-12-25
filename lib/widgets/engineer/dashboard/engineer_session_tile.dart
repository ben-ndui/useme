import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:useme/core/models/models_exports.dart';

/// A session tile for engineer dashboard
class EngineerSessionTile extends StatelessWidget {
  final Session session;
  final bool showDate;
  final String locale;

  const EngineerSessionTile({
    super.key,
    required this.session,
    this.showDate = false,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeFormat = DateFormat('HH:mm', locale);
    final dateFormat = DateFormat('EEE d MMM', locale);

    return GestureDetector(
      onTap: () => context.push('/engineer/sessions/${session.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getStatusColor(session.displayStatus).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FaIcon(
                  _getTypeIcon(session.type),
                  size: 18,
                  color: _getStatusColor(session.displayStatus),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.artistName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.clock, size: 10, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        showDate
                            ? '${dateFormat.format(session.scheduledStart)} • ${timeFormat.format(session.scheduledStart)}'
                            : '${timeFormat.format(session.scheduledStart)} - ${timeFormat.format(session.scheduledEnd)}',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildAction(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(ColorScheme colorScheme) {
    if (session.displayStatus == SessionStatus.confirmed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Go',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onPrimary),
        ),
      );
    }
    if (session.displayStatus == SessionStatus.inProgress) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
        child: const FaIcon(FontAwesomeIcons.play, size: 14, color: Colors.white),
      );
    }
    return FaIcon(FontAwesomeIcons.chevronRight, size: 14, color: colorScheme.onSurfaceVariant);
  }

  Color _getStatusColor(SessionStatus status) {
    return switch (status) {
      SessionStatus.pending => Colors.orange,
      SessionStatus.confirmed => Colors.blue,
      SessionStatus.inProgress => Colors.green,
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
