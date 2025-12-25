import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/services/engineer_availability_service.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Engineer selection section for accept booking sheet
class BookingEngineerSelector extends StatelessWidget {
  final List<AvailableEngineer> availableEngineers;
  final Set<String> selectedEngineerIds;
  final bool proposeMode;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<String> onEngineerToggled;

  const BookingEngineerSelector({
    super.key,
    required this.availableEngineers,
    required this.selectedEngineerIds,
    required this.proposeMode,
    required this.onModeChanged,
    required this.onEngineerToggled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final availableCount = availableEngineers.where((e) => e.isAvailable).length;
    final selectedCount = selectedEngineerIds.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(theme, l10n, availableCount),
        const SizedBox(height: 8),
        _buildModeSelector(theme, l10n),
        const SizedBox(height: 12),
        if (proposeMode) ...[
          if (selectedCount > 0) _buildSelectedCount(theme, selectedCount),
          _buildEngineerList(theme, l10n),
        ] else
          _buildAssignLaterInfo(theme, l10n),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n, int availableCount) {
    return Row(
      children: [
        Expanded(child: Text(l10n.assignEngineer, style: theme.textTheme.titleSmall)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: availableCount > 0
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.orange.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$availableCount ${l10n.available}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: availableCount > 0 ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelector(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _ModeChip(
            icon: FontAwesomeIcons.userGroup,
            label: l10n.proposeToEngineers,
            isSelected: proposeMode,
            onTap: () => onModeChanged(true),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ModeChip(
            icon: FontAwesomeIcons.clock,
            label: l10n.assignLater,
            isSelected: !proposeMode,
            onTap: () => onModeChanged(false),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedCount(ThemeData theme, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$count ingénieur${count > 1 ? 's' : ''} sélectionné${count > 1 ? 's' : ''}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEngineerList(ThemeData theme, AppLocalizations l10n) {
    if (availableEngineers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            FaIcon(FontAwesomeIcons.userSlash, size: 20, color: theme.colorScheme.error),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                l10n.noEngineersAvailable,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: availableEngineers
          .map((e) => _EngineerTile(
                engineer: e,
                isSelected: selectedEngineerIds.contains(e.user.uid),
                onToggle: () => onEngineerToggled(e.user.uid),
              ))
          .toList(),
    );
  }

  Widget _buildAssignLaterInfo(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.clockRotateLeft, size: 20, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.assignLaterDescription,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, size: 14, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EngineerTile extends StatelessWidget {
  final AvailableEngineer engineer;
  final bool isSelected;
  final VoidCallback onToggle;

  const _EngineerTile({
    required this.engineer,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAvailable = engineer.isAvailable;

    return GestureDetector(
      onTap: isAvailable ? onToggle : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : isAvailable
                    ? theme.colorScheme.outline.withValues(alpha: 0.3)
                    : theme.colorScheme.error.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: isAvailable ? (_) => onToggle() : null,
              activeColor: theme.colorScheme.primary,
            ),
            _buildAvatar(theme),
            const SizedBox(width: 12),
            _buildInfo(theme),
            _buildStatus(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: theme.colorScheme.primaryContainer,
      backgroundImage: engineer.user.photoURL != null ? NetworkImage(engineer.user.photoURL!) : null,
      child: engineer.user.photoURL == null
          ? FaIcon(FontAwesomeIcons.user, size: 14, color: theme.colorScheme.primary)
          : null,
    );
  }

  Widget _buildInfo(ThemeData theme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            engineer.user.displayName ?? engineer.user.name ?? 'Ingénieur',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: engineer.isAvailable ? null : theme.colorScheme.outline,
            ),
          ),
          if (!engineer.isAvailable && engineer.unavailabilityReason != null)
            Text(
              engineer.unavailabilityReason!,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
            ),
        ],
      ),
    );
  }

  Widget _buildStatus(ThemeData theme) {
    if (engineer.isAvailable) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Dispo',
          style: theme.textTheme.labelSmall?.copyWith(color: Colors.green, fontWeight: FontWeight.w600),
        ),
      );
    }
    return FaIcon(FontAwesomeIcons.ban, size: 16, color: theme.colorScheme.error);
  }
}
