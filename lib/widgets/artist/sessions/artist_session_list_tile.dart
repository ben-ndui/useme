import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Session tile for artist list view
class ArtistSessionListTile extends StatelessWidget {
  final Session session;
  final bool isPast;
  final VoidCallback onTap;

  const ArtistSessionListTile({
    super.key,
    required this.session,
    required this.isPast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat('EEE d MMM', locale);
    final timeFormat = DateFormat('HH:mm', locale);

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
              _buildTypeIcon(colorScheme),
              const SizedBox(width: 12),
              Expanded(child: _buildSessionInfo(colorScheme, dateFormat, timeFormat)),
              _buildTrailing(colorScheme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: FaIcon(_getTypeIcon(session.types.firstOrNull), size: 16, color: _getStatusColor()),
    );
  }

  Widget _buildSessionInfo(ColorScheme colorScheme, DateFormat dateFormat, DateFormat timeFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          session.typeLabel,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            FaIcon(
              FontAwesomeIcons.calendar,
              size: 10,
              color: isPast ? colorScheme.onSurfaceVariant : colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              '${dateFormat.format(session.scheduledStart)} • ${timeFormat.format(session.scheduledStart)}',
              style: TextStyle(
                fontSize: 12,
                color: isPast ? colorScheme.onSurfaceVariant : colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrailing(ColorScheme colorScheme, AppLocalizations l10n) {
    if (session.displayStatus == SessionStatus.completed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          l10n.completedStatus,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.green),
        ),
      );
    }
    return FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: colorScheme.onSurfaceVariant);
  }

  Color _getStatusColor() {
    return switch (session.displayStatus) {
      SessionStatus.pending => Colors.orange,
      SessionStatus.confirmed => Colors.green,
      SessionStatus.inProgress => Colors.blue,
      SessionStatus.completed => Colors.grey,
      SessionStatus.cancelled || SessionStatus.noShow => Colors.red,
    };
  }

  IconData _getTypeIcon(SessionType? type) {
    return switch (type) {
      SessionType.recording => FontAwesomeIcons.microphone,
      SessionType.mix || SessionType.mixing => FontAwesomeIcons.sliders,
      SessionType.mastering => FontAwesomeIcons.compactDisc,
      SessionType.editing => FontAwesomeIcons.scissors,
      _ => FontAwesomeIcons.music,
    };
  }
}
