import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Check-in/check-out section of the session tracking screen
class SessionTrackingCheckin extends StatelessWidget {
  final SessionIntervention intervention;
  final SessionStatus displayStatus;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;

  const SessionTrackingCheckin({
    super.key,
    required this.intervention,
    required this.displayStatus,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isCheckedIn = intervention.hasCheckedIn;
    final isCheckedOut = intervention.hasCheckedOut;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.checkIn,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (!isCheckedIn) _buildCheckInButton(l10n),
            if (isCheckedIn) ...[
              _buildCheckedInBanner(context, l10n),
              if (!isCheckedOut) ...[
                const SizedBox(height: 12),
                _buildCheckOutButton(l10n),
              ],
            ],
            if (isCheckedOut) ...[
              const SizedBox(height: 12),
              _buildCheckedOutBanner(context, l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onCheckIn,
        icon: const FaIcon(FontAwesomeIcons.rightToBracket, size: 16),
        label: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(l10n.checkInArrival),
        ),
      ),
    );
  }

  Widget _buildCheckedInBanner(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm', 'fr_FR');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          FaIcon(
            FontAwesomeIcons.circleCheck,
            size: 20,
            color: Colors.green.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.arrivalChecked,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
                if (intervention.checkinTime != null)
                  Text(
                    timeFormat.format(intervention.checkinTime!),
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckOutButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onCheckOut,
        icon: const FaIcon(FontAwesomeIcons.rightFromBracket, size: 16),
        label: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(l10n.checkOutDeparture),
        ),
      ),
    );
  }

  Widget _buildCheckedOutBanner(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm', 'fr_FR');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          FaIcon(
            FontAwesomeIcons.circleCheck,
            size: 20,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.checkOutDeparture,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                if (intervention.checkoutTime != null)
                  Text(
                    timeFormat.format(intervention.checkoutTime!),
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
