import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/services/engineer_availability_service.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Engineer selector tile for session request
class SessionEngineerSelector extends StatelessWidget {
  final AvailableEngineer? selectedEngineer;
  final int availableCount;
  final VoidCallback onTap;

  const SessionEngineerSelector({
    super.key,
    required this.selectedEngineer,
    required this.availableCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: selectedEngineer != null
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            _buildAvatar(theme, l10n),
            const SizedBox(width: 12),
            _buildInfo(theme, l10n),
            _buildBadge(theme, l10n),
            const SizedBox(width: 8),
            FaIcon(FontAwesomeIcons.chevronRight, size: 14, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, AppLocalizations l10n) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: selectedEngineer != null
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
      ),
      child: selectedEngineer != null && selectedEngineer!.user.photoURL != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.network(
                selectedEngineer!.user.photoURL!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    selectedEngineer!.user.name?[0].toUpperCase() ?? 'I',
                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                ),
              ),
            )
          : Center(
              child: FaIcon(
                selectedEngineer != null ? FontAwesomeIcons.userCheck : FontAwesomeIcons.shuffle,
                size: 18,
                color: selectedEngineer != null ? theme.colorScheme.primary : theme.colorScheme.outline,
              ),
            ),
    );
  }

  Widget _buildInfo(ThemeData theme, AppLocalizations l10n) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedEngineer != null ? (selectedEngineer!.user.name ?? l10n.engineer) : l10n.noPreference,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            selectedEngineer != null ? l10n.engineerSelectedLabel : l10n.letStudioChoose,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(FontAwesomeIcons.userGear, size: 10, color: Colors.green),
          const SizedBox(width: 4),
          Text(
            l10n.availableCount(availableCount),
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
