import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/services/engineer_availability_service.dart';

/// Bottom sheet pour sélectionner un ingénieur disponible
class EngineerSelectorBottomSheet extends StatelessWidget {
  final List<AvailableEngineer> engineers;
  final AvailableEngineer? selectedEngineer;

  const EngineerSelectorBottomSheet({
    super.key,
    required this.engineers,
    this.selectedEngineer,
  });

  static Future<AvailableEngineer?> show(
    BuildContext context,
    List<AvailableEngineer> engineers, {
    AvailableEngineer? selectedEngineer,
  }) {
    return showModalBottomSheet<AvailableEngineer>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EngineerSelectorBottomSheet(
        engineers: engineers,
        selectedEngineer: selectedEngineer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableEngineers = engineers.where((e) => e.isAvailable).toList();
    final unavailableEngineers = engineers.where((e) => !e.isAvailable).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.userGear,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choisir un ingénieur',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${availableEngineers.length} disponible(s)',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  FaIcon(FontAwesomeIcons.circleInfo, size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Optionnel : laissez le studio assigner un ingénieur automatiquement',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // "No preference" option
            _buildEngineerTile(
              context,
              null,
              isSelected: selectedEngineer == null,
              onTap: () => Navigator.pop(context, null),
            ),
            const Divider(height: 24),

            // Available engineers
            if (availableEngineers.isNotEmpty) ...[
              Text(
                'DISPONIBLES',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              ...availableEngineers.map((e) => _buildEngineerTile(
                context,
                e,
                isSelected: selectedEngineer?.user.uid == e.user.uid,
                onTap: () => Navigator.pop(context, e),
              )),
            ],

            // Unavailable engineers
            if (unavailableEngineers.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'INDISPONIBLES',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              ...unavailableEngineers.map((e) => _buildEngineerTile(
                context,
                e,
                isSelected: false,
                onTap: null,
              )),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineerTile(
    BuildContext context,
    AvailableEngineer? engineer, {
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isNoPreference = engineer == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isNoPreference
                    ? theme.colorScheme.surfaceContainerHighest
                    : (engineer.isAvailable ? Colors.green : theme.colorScheme.outline)
                        .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: isNoPreference
                  ? Center(
                      child: FaIcon(
                        FontAwesomeIcons.shuffle,
                        size: 16,
                        color: theme.colorScheme.outline,
                      ),
                    )
                  : engineer.user.photoURL != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.network(
                            engineer.user.photoURL!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildInitials(theme, engineer),
                          ),
                        )
                      : _buildInitials(theme, engineer),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isNoPreference ? 'Pas de préférence' : (engineer.user.name ?? 'Ingénieur'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: onTap == null ? theme.colorScheme.outline : null,
                    ),
                  ),
                  if (!isNoPreference) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: engineer.isAvailable ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          engineer.isAvailable
                              ? 'Disponible'
                              : (engineer.unavailabilityReason ?? 'Indisponible'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: engineer.isAvailable ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ] else
                    Text(
                      'Le studio assignera un ingénieur',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),

            // Check
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.check, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitials(ThemeData theme, AvailableEngineer engineer) {
    final name = engineer.user.name ?? 'I';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'I';

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: engineer.isAvailable ? Colors.green : theme.colorScheme.outline,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
