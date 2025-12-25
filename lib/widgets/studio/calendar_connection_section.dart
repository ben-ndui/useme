import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/blocs/calendar/calendar_exports.dart';
import '../../widgets/common/snackbar/app_snackbar.dart';

/// Section de connexion calendrier pour les paramètres studio
class CalendarConnectionSection extends StatelessWidget {
  final String userId;

  const CalendarConnectionSection({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CalendarBloc, CalendarState>(
      listener: (context, state) {
        if (state is CalendarErrorState) {
          AppSnackBar.error(context, state.message);
        } else if (state is UnavailabilityAddedState) {
          AppSnackBar.success(context, 'Indisponibilité ajoutée');
        } else if (state is UnavailabilityDeletedState) {
          AppSnackBar.success(context, 'Indisponibilité supprimée');
        }
      },
      builder: (context, state) {
        if (state is CalendarLoadingState) {
          return _buildLoadingState(context);
        }

        if (state is CalendarConnectedState) {
          return _buildConnectedState(context, state);
        }

        return _buildDisconnectedState(context);
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildDisconnectedState(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: FaIcon(FontAwesomeIcons.calendar, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calendrier',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Non connecté',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Connectez votre agenda Google pour synchroniser automatiquement vos disponibilités.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  context.read<CalendarBloc>().add(
                        ConnectGoogleCalendarEvent(userId: userId),
                      );
                },
                icon: const FaIcon(FontAwesomeIcons.google, size: 16),
                label: const Text('Connecter Google Calendar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedState(BuildContext context, CalendarConnectedState state) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.circleCheck,
                      size: 20,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calendrier connecté',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        state.connection.email ?? 'Google Calendar',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.isSyncing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Stats
            Row(
              children: [
                _StatItem(
                  icon: FontAwesomeIcons.calendarXmark,
                  value: '${state.unavailabilities.length}',
                  label: 'Indispos',
                ),
                const SizedBox(width: 24),
                _StatItem(
                  icon: FontAwesomeIcons.clockRotateLeft,
                  value: state.connection.lastSync != null
                      ? dateFormat.format(state.connection.lastSync!)
                      : 'Jamais',
                  label: 'Dernier sync',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isSyncing
                        ? null
                        : () {
                            context.read<CalendarBloc>().add(
                                  SyncCalendarEvent(userId: userId),
                                );
                          },
                    icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 14),
                    label: const Text('Synchroniser'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDisconnectDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    icon: const FaIcon(FontAwesomeIcons.linkSlash, size: 14),
                    label: const Text('Déconnecter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnecter le calendrier ?'),
        content: const Text(
          'Vos indisponibilités synchronisées seront supprimées. '
          'Les indisponibilités manuelles seront conservées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CalendarBloc>().add(
                    DisconnectCalendarEvent(userId: userId),
                  );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        FaIcon(icon, size: 14, color: theme.colorScheme.outline),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
