import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Session tile for artist calendar view
class ArtistSessionTile extends StatelessWidget {
  final Session session;
  final VoidCallback onTap;

  const ArtistSessionTile({
    super.key,
    required this.session,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
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
            Expanded(child: _buildSessionInfo(colorScheme, l10n)),
            const SizedBox(width: 8),
            FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: colorScheme.onSurfaceVariant),
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

  Widget _buildSessionInfo(ColorScheme colorScheme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                session.typeLabel,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildStatusBadge(colorScheme, l10n),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            FaIcon(_getTypeIcon(session.type), size: 10, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l10n.hoursOfSession(session.durationMinutes ~/ 60),
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

  Widget _buildStatusBadge(ColorScheme colorScheme, AppLocalizations l10n) {
    final (color, label) = _getStatusInfo(l10n);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }

  (Color, String) _getStatusInfo(AppLocalizations l10n) {
    return switch (session.displayStatus) {
      SessionStatus.pending => (Colors.orange, l10n.pendingStatus),
      SessionStatus.confirmed => (Colors.green, l10n.confirmedStatus),
      SessionStatus.inProgress => (Colors.blue, l10n.inProgressStatus),
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
