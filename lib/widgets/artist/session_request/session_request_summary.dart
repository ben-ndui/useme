import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:useme/core/models/studio_room.dart';
import 'package:useme/core/services/engineer_availability_service.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Summary card showing selected session details
class SessionRequestSummary extends StatelessWidget {
  final DateTime date;
  final DateTime slotStart;
  final DateTime slotEnd;
  final StudioRoom? selectedRoom;
  final AvailableEngineer? selectedEngineer;

  const SessionRequestSummary({
    super.key,
    required this.date,
    required this.slotStart,
    required this.slotEnd,
    this.selectedRoom,
    this.selectedEngineer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat('EEEE d MMMM yyyy', locale);
    final timeFormat = DateFormat('HH:mm', locale);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildHeader(theme, l10n, dateFormat, timeFormat),
          if (selectedRoom != null) _buildRoomInfo(theme, l10n),
          if (selectedEngineer != null) _buildEngineerInfo(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n, DateFormat dateFormat, DateFormat timeFormat) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: FaIcon(FontAwesomeIcons.check, size: 16, color: Colors.green),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.summaryLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                dateFormat.format(date),
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.green.shade700),
              ),
              Text(
                '${timeFormat.format(slotStart)} - ${timeFormat.format(slotEnd)}',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.green.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomInfo(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        const Divider(height: 24),
        Row(
          children: [
            FaIcon(
              selectedRoom!.requiresEngineer ? FontAwesomeIcons.headphones : FontAwesomeIcons.doorOpen,
              size: 14,
              color: Colors.green.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              selectedRoom!.name,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.green.shade600),
            ),
            const SizedBox(width: 8),
            Text(
              selectedRoom!.requiresEngineer ? '(${l10n.withEngineer})' : '(${l10n.selfService})',
              style: theme.textTheme.labelSmall?.copyWith(color: Colors.green.shade500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEngineerInfo(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        const Divider(height: 24),
        Row(
          children: [
            FaIcon(FontAwesomeIcons.userCheck, size: 14, color: Colors.green.shade600),
            const SizedBox(width: 8),
            Text(
              '${l10n.engineer} : ${selectedEngineer!.user.name ?? l10n.notSpecified}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.green.shade600),
            ),
          ],
        ),
      ],
    );
  }
}
