import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';

/// A colored chip displaying session status
class SessionStatusChip extends StatelessWidget {
  final SessionStatus status;
  final AppLocalizations l10n;

  const SessionStatusChip({super.key, required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (status) {
      SessionStatus.pending => (Colors.orange, FontAwesomeIcons.hourglass, l10n.waitingStatus),
      SessionStatus.confirmed => (Colors.blue, FontAwesomeIcons.circleCheck, l10n.confirmedStatus),
      SessionStatus.inProgress => (Colors.green, FontAwesomeIcons.play, l10n.inProgressStatus),
      SessionStatus.completed => (Colors.grey, FontAwesomeIcons.check, l10n.completedStatus),
      SessionStatus.cancelled => (Colors.red, FontAwesomeIcons.xmark, l10n.cancelledStatus),
      SessionStatus.noShow => (Colors.red, FontAwesomeIcons.userXmark, l10n.noShowStatus),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 10, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
