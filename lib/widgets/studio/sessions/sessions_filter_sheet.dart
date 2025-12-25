import 'package:flutter/material.dart';
import 'package:useme/core/models/session.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Filter bottom sheet for sessions
class SessionsFilterSheet extends StatelessWidget {
  final SessionStatus? selectedStatus;
  final ValueChanged<SessionStatus?> onStatusSelected;

  const SessionsFilterSheet({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.filterByStatus,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: l10n.all,
                  isSelected: selectedStatus == null,
                  onTap: () => onStatusSelected(null),
                ),
                _FilterChip(
                  label: l10n.pendingStatus,
                  color: Colors.orange,
                  isSelected: selectedStatus == SessionStatus.pending,
                  onTap: () => onStatusSelected(SessionStatus.pending),
                ),
                _FilterChip(
                  label: l10n.confirmed,
                  color: Colors.blue,
                  isSelected: selectedStatus == SessionStatus.confirmed,
                  onTap: () => onStatusSelected(SessionStatus.confirmed),
                ),
                _FilterChip(
                  label: l10n.inProgressStatus,
                  color: Colors.green,
                  isSelected: selectedStatus == SessionStatus.inProgress,
                  onTap: () => onStatusSelected(SessionStatus.inProgress),
                ),
                _FilterChip(
                  label: l10n.completedStatus,
                  color: Colors.grey,
                  isSelected: selectedStatus == SessionStatus.completed,
                  onTap: () => onStatusSelected(SessionStatus.completed),
                ),
                _FilterChip(
                  label: l10n.cancelledStatus,
                  color: Colors.red,
                  isSelected: selectedStatus == SessionStatus.cancelled,
                  onTap: () => onStatusSelected(SessionStatus.cancelled),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return Material(
      color: isSelected ? chipColor : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
