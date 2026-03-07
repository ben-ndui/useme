import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/pro_profile.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Sélecteur de types de pro (multi-sélection avec chips).
class ProTypeSelector extends StatelessWidget {
  final List<ProType> selectedTypes;
  final ValueChanged<List<ProType>> onChanged;

  const ProTypeSelector({
    super.key,
    required this.selectedTypes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.proProfileTypeLabel,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.proProfileTypeHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ProType.values.map((type) {
            final isSelected = selectedTypes.contains(type);
            return FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    _iconForType(type),
                    size: 14,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(type.label),
                ],
              ),
              selectedColor: theme.colorScheme.primary,
              checkmarkColor: theme.colorScheme.onPrimary,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              onSelected: (selected) {
                final updated = List<ProType>.from(selectedTypes);
                if (selected) {
                  updated.add(type);
                } else {
                  updated.remove(type);
                }
                onChanged(updated);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _iconForType(ProType type) {
    switch (type) {
      case ProType.soundEngineer:
        return FontAwesomeIcons.sliders;
      case ProType.musician:
        return FontAwesomeIcons.guitar;
      case ProType.artisticDirector:
        return FontAwesomeIcons.wandMagicSparkles;
      case ProType.producer:
        return FontAwesomeIcons.headphones;
      case ProType.vocalist:
        return FontAwesomeIcons.microphone;
      case ProType.composer:
        return FontAwesomeIcons.music;
    }
  }
}
