import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Widget pour afficher les disponibilites
class AIAvailabilityCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const AIAvailabilityCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final slots = (data['slots'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final date = data['date'];

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purple.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, theme, date),
          Padding(
            padding: const EdgeInsets.all(12),
            child: slots.isEmpty
                ? Text(l10n.noSlotAvailable, style: TextStyle(color: theme.colorScheme.outline))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: slots.map((s) => _buildSlotChip(theme, s)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotChip(ThemeData theme, Map<String, dynamic> slot) {
    final isAvailable = slot['available'] ?? true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green.withValues(alpha:0.1) : Colors.red.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAvailable ? Colors.green.withValues(alpha:0.3) : Colors.red.withValues(alpha:0.3),
        ),
      ),
      child: Text(
        slot['time'] ?? slot['startTime'] ?? '',
        style: theme.textTheme.bodySmall?.copyWith(
          color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, String? date) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha:0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.clock, size: 14, color: Colors.purple),
          const SizedBox(width: 8),
          Text(l10n.availabilities, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          if (date != null) ...[
            const Spacer(),
            Text(date, style: theme.textTheme.bodySmall?.copyWith(color: Colors.purple)),
          ],
        ],
      ),
    );
  }
}
