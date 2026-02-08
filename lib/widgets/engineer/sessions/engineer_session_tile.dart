import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Session tile for engineer calendar view
class EngineerSessionTile extends StatelessWidget {
  final Session session;
  final AppLocalizations l10n;
  final String locale;
  final VoidCallback onTap;

  const EngineerSessionTile({
    super.key,
    required this.session,
    required this.l10n,
    required this.locale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeFormat = DateFormat('HH:mm', locale);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            _buildTimeBox(colorScheme, timeFormat),
            const SizedBox(width: 14),
            Expanded(child: _buildSessionInfo(colorScheme)),
            const SizedBox(width: 8),
            _buildActionIndicator(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBox(ColorScheme colorScheme, DateFormat timeFormat) {
    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            timeFormat.format(session.scheduledStart),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                session.artistName,
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
            FaIcon(_getTypeIcon(session.types.firstOrNull ?? SessionType.other), size: 10, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${session.typeLabel} • ${session.durationMinutes ~/ 60}h',
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildActionIndicator(ColorScheme colorScheme) {
    if (session.displayStatus == SessionStatus.confirmed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(8)),
        child: Text('Go', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onPrimary)),
      );
    }
    if (session.displayStatus == SessionStatus.inProgress) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
        child: const FaIcon(FontAwesomeIcons.play, size: 12, color: Colors.white),
      );
    }
    return FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: colorScheme.onSurfaceVariant);
  }

  (Color, String) _getStatusInfo() {
    return switch (session.displayStatus) {
      SessionStatus.pending => (Colors.orange, l10n.pendingStatus),
      SessionStatus.confirmed => (Colors.blue, l10n.confirmedStatus),
      SessionStatus.inProgress => (Colors.green, l10n.inProgressStatus),
      SessionStatus.completed => (Colors.grey, l10n.completedStatus),
      SessionStatus.cancelled => (Colors.red, l10n.cancelledStatus),
      SessionStatus.noShow => (Colors.red, l10n.noShowStatus),
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
