import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/studio_room.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/common/app_loader.dart';

/// Studio rooms management page
class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rooms)),
      body: BlocBuilder<StudioRoomBloc, StudioRoomState>(
        builder: (context, state) {
          if (state.status == StudioRoomStatus.loading) {
            return const AppLoader();
          }

          if (state.rooms.isEmpty) {
            return _buildEmptyState(context, l10n);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.rooms.length,
            itemBuilder: (context, index) => _buildRoomCard(context, state.rooms[index], l10n),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.roomAdd),
        icon: const FaIcon(FontAwesomeIcons.plus, size: 18),
        label: Text(l10n.addRoom),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.doorClosed, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(l10n.noRooms, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 8),
          Text(l10n.createRoomsHint, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.roomAdd),
            icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
            label: Text(l10n.addRoom),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, StudioRoom room, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/rooms/${room.id}/edit'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: room.requiresEngineer ? theme.colorScheme.primaryContainer : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    room.requiresEngineer ? FontAwesomeIcons.headphones : FontAwesomeIcons.doorOpen,
                    size: 20,
                    color: room.requiresEngineer ? theme.colorScheme.primary : Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    if (room.description != null)
                      Text(
                        room.description!,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildAccessChip(theme, room.requiresEngineer, l10n),
                        if (room.hourlyRate != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${room.hourlyRate!.toStringAsFixed(0)}€/h',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Status & arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: room.isActive ? Colors.green.shade50 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      room.isActive ? l10n.active : l10n.inactive,
                      style: TextStyle(
                        fontSize: 11,
                        color: room.isActive ? Colors.green.shade700 : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FaIcon(FontAwesomeIcons.chevronRight, size: 14, color: theme.colorScheme.outline),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccessChip(ThemeData theme, bool requiresEngineer, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: requiresEngineer ? theme.colorScheme.primaryContainer : Colors.green.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        requiresEngineer ? l10n.withEngineer : l10n.selfService,
        style: TextStyle(
          fontSize: 10,
          color: requiresEngineer ? theme.colorScheme.primary : Colors.green.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
