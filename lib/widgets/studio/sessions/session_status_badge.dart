import 'package:flutter/material.dart';
import 'package:useme/core/models/session.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Status badge for session cards
class SessionStatusBadge extends StatelessWidget {
  final SessionStatus status;

  const SessionStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (color, label) = _getStatusInfo(l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  (Color, String) _getStatusInfo(AppLocalizations l10n) {
    return switch (status) {
      SessionStatus.pending => (Colors.orange, l10n.waitingStatus),
      SessionStatus.confirmed => (Colors.blue, l10n.confirmedStatus),
      SessionStatus.inProgress => (Colors.green, l10n.inProgressStatus),
      SessionStatus.completed => (Colors.grey, l10n.completedStatus),
      SessionStatus.cancelled => (Colors.red, l10n.cancelledStatus),
      SessionStatus.noShow => (Colors.red, l10n.noShowStatus),
    };
  }
}

/// Returns the color for a given session status
Color getSessionStatusColor(SessionStatus status) {
  return switch (status) {
    SessionStatus.pending => Colors.orange,
    SessionStatus.confirmed => Colors.blue,
    SessionStatus.inProgress => Colors.green,
    SessionStatus.completed => Colors.grey,
    SessionStatus.cancelled || SessionStatus.noShow => Colors.red,
  };
}
