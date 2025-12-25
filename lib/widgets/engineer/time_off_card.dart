import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Card affichant une indisponibilité
class TimeOffCard extends StatelessWidget {
  final TimeOff timeOff;
  final VoidCallback onDelete;

  const TimeOffCard({
    super.key,
    required this.timeOff,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat('d MMM yyyy', locale);

    final isActive = timeOff.isActive;
    final isFuture = timeOff.isFuture;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primaryContainer
                  : isFuture
                      ? theme.colorScheme.tertiaryContainer
                      : theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: FaIcon(
                _getIcon(),
                size: 18,
                color: isActive
                    ? theme.colorScheme.primary
                    : isFuture
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.outline,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date range
                Text(
                  _formatDateRange(dateFormat),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                // Reason + duration
                Row(
                  children: [
                    if (timeOff.reason != null) ...[
                      Text(
                        timeOff.reason!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(color: theme.colorScheme.outline),
                      ),
                    ],
                    Text(
                      timeOff.durationDays > 1
                          ? l10n.daysCountPlural(timeOff.durationDays)
                          : l10n.daysCount(timeOff.durationDays),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),

                // Active badge
                if (isActive) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      l10n.inProgress,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Delete button
          IconButton(
            onPressed: () => _confirmDelete(context, l10n),
            icon: FaIcon(
              FontAwesomeIcons.trash,
              size: 16,
              color: Colors.red.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    final reason = timeOff.reason?.toLowerCase() ?? '';
    if (reason.contains('vacances')) return FontAwesomeIcons.umbrellaBeach;
    if (reason.contains('maladie')) return FontAwesomeIcons.houseMedical;
    if (reason.contains('rdv') || reason.contains('médical')) {
      return FontAwesomeIcons.stethoscope;
    }
    if (reason.contains('formation')) return FontAwesomeIcons.graduationCap;
    if (reason.contains('famille') || reason.contains('familial')) {
      return FontAwesomeIcons.peopleRoof;
    }
    return FontAwesomeIcons.calendarXmark;
  }

  String _formatDateRange(DateFormat format) {
    final startStr = format.format(timeOff.start);
    final endStr = format.format(timeOff.end);

    // Même jour
    if (timeOff.start.year == timeOff.end.year &&
        timeOff.start.month == timeOff.end.month &&
        timeOff.start.day == timeOff.end.day) {
      return startStr;
    }

    return '$startStr → $endStr';
  }

  void _confirmDelete(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTimeOff),
        content: Text(l10n.deleteTimeOffConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.deleteTimeOff),
          ),
        ],
      ),
    );
  }
}
