import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/studio_room.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Room selector widget for session request
class SessionRoomSelector extends StatelessWidget {
  final List<StudioRoom> availableRooms;
  final StudioRoom? selectedRoom;
  final bool isLoading;
  final ValueChanged<StudioRoom?> onRoomSelected;

  const SessionRoomSelector({
    super.key,
    required this.availableRooms,
    required this.selectedRoom,
    required this.isLoading,
    required this.onRoomSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableRooms.map((room) {
        final isSelected = selectedRoom?.id == room.id;
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(room.name),
              const SizedBox(width: 6),
              FaIcon(
                room.requiresEngineer ? FontAwesomeIcons.headphones : FontAwesomeIcons.doorOpen,
                size: 12,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : (room.requiresEngineer ? theme.colorScheme.primary : Colors.green),
              ),
            ],
          ),
          selected: isSelected,
          onSelected: (_) => onRoomSelected(isSelected ? null : room),
        );
      }).toList(),
    );
  }
}

/// Self-service info card shown when a self-service room is selected
class SelfServiceInfoCard extends StatelessWidget {
  const SelfServiceInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.doorOpen, size: 16, color: Colors.green),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.selfService,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.selfServiceDesc,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.green.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
