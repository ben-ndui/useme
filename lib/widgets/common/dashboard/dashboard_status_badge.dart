import 'package:flutter/material.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';

/// A status badge widget for sessions in dashboards
class DashboardStatusBadge extends StatelessWidget {
  final SessionStatus status;
  final AppLocalizations l10n;

  const DashboardStatusBadge({
    super.key,
    required this.status,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      SessionStatus.pending => (Colors.orange, l10n.waitingStatus),
      SessionStatus.confirmed => (Colors.blue, l10n.confirmedStatus),
      SessionStatus.inProgress => (Colors.green, l10n.inProgressStatus),
      SessionStatus.completed => (Colors.grey, l10n.completedStatus),
      SessionStatus.cancelled => (Colors.red, l10n.cancelledStatus),
      SessionStatus.noShow => (Colors.red, l10n.noShowStatus),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
