import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/session.dart';

/// Session type selector widget
class SessionTypeSelector extends StatelessWidget {
  final Set<SessionType> selectedTypes;
  final ValueChanged<Set<SessionType>> onTypesChanged;

  const SessionTypeSelector({
    super.key,
    required this.selectedTypes,
    required this.onTypesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SessionType.recording,
            SessionType.mix,
            SessionType.mastering,
            SessionType.editing,
          ].map((type) => _buildTypeChip(type)).toList(),
        ),
        if (selectedTypes.length > 1) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(FontAwesomeIcons.layerGroup, size: 12, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  SessionTypeExtension.combinedLabel(selectedTypes.toList()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTypeChip(SessionType type) {
    final isSelected = selectedTypes.contains(type);
    return FilterChip(
      label: Text(type.label),
      selected: isSelected,
      onSelected: (selected) {
        final newTypes = Set<SessionType>.from(selectedTypes);
        if (selected) {
          newTypes.add(type);
        } else if (newTypes.length > 1) {
          newTypes.remove(type);
        }
        onTypesChanged(newTypes);
      },
      avatar: isSelected ? null : FaIcon(_getTypeIcon(type), size: 14),
      showCheckmark: true,
    );
  }

  IconData _getTypeIcon(SessionType type) {
    switch (type) {
      case SessionType.recording:
        return FontAwesomeIcons.microphone;
      case SessionType.mix:
      case SessionType.mixing:
        return FontAwesomeIcons.sliders;
      case SessionType.mastering:
        return FontAwesomeIcons.compactDisc;
      case SessionType.editing:
        return FontAwesomeIcons.scissors;
      default:
        return FontAwesomeIcons.music;
    }
  }
}
