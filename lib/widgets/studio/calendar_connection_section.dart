import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/blocs/calendar/calendar_exports.dart';
import '../../core/models/unavailability.dart';
import '../../l10n/app_localizations.dart';
import '../../routing/app_routes.dart';
import '../../widgets/common/snackbar/app_snackbar.dart';

/// Section de connexion calendrier pour les paramètres studio
class CalendarConnectionSection extends StatelessWidget {
  final String userId;

  const CalendarConnectionSection({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CalendarBloc, CalendarState>(
      listener: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        if (state is CalendarErrorState) {
          AppSnackBar.error(context, state.message);
        } else if (state is UnavailabilityAddedState) {
          AppSnackBar.success(context, l10n.unavailabilityAdded);
        } else if (state is UnavailabilityDeletedState) {
          AppSnackBar.success(context, l10n.unavailabilityDeleted);
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
    final l10n = AppLocalizations.of(context)!;

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
                        l10n.calendar,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        l10n.notConnected,
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
              l10n.connectGoogleCalendarDesc,
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
                label: Text(l10n.connectGoogleCalendar),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedState(BuildContext context, CalendarConnectedState state) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
                        l10n.calendarConnected,
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
                  label: l10n.unavailabilities,
                ),
                const SizedBox(width: 24),
                _StatItem(
                  icon: FontAwesomeIcons.clockRotateLeft,
                  value: state.connection.lastSync != null
                      ? dateFormat.format(state.connection.lastSync!)
                      : l10n.never,
                  label: l10n.lastSync,
                ),
              ],
            ),

            // Unavailabilities list (show up to 5 upcoming)
            if (state.unavailabilities.isNotEmpty) ...[
              const SizedBox(height: 12),
              _UnavailabilitiesList(unavailabilities: state.unavailabilities),
            ],

            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                    ),
                    onPressed: state.isSyncing
                        ? null
                        : () async {
                            await context.push(
                              '${AppRoutes.calendarImportReview}?userId=$userId',
                            );
                            // Recharger le statut après retour du review screen
                            if (context.mounted) {
                              context.read<CalendarBloc>().add(
                                    LoadCalendarStatusEvent(userId: userId),
                                  );
                            }
                          },
                    icon: const FaIcon(FontAwesomeIcons.fileImport, size: 14),
                    label: Text(l10n.reviewAndImport),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDisconnectDialog(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                      foregroundColor: theme.colorScheme.error,
                    ),
                    icon: const FaIcon(FontAwesomeIcons.linkSlash, size: 14),
                    label: Text(l10n.disconnect),
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.disconnectCalendar),
        content: Text(l10n.disconnectCalendarWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
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
            child: Text(l10n.disconnect),
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

/// Liste des indisponibilités (affiche les 5 prochaines)
class _UnavailabilitiesList extends StatelessWidget {
  final List<Unavailability> unavailabilities;

  const _UnavailabilitiesList({required this.unavailabilities});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    // Trier par date et prendre les 5 prochaines
    final upcoming = unavailabilities
        .where((u) => u.end.isAfter(now))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final displayList = upcoming.take(5).toList();

    if (displayList.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...displayList.map((u) => _UnavailabilityTile(unavailability: u)),
          if (upcoming.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+${upcoming.length - 5} autres',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UnavailabilityTile extends StatelessWidget {
  final Unavailability unavailability;

  const _UnavailabilityTile({required this.unavailability});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM HH:mm', 'fr_FR');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              unavailability.title ?? 'Indisponible',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            dateFormat.format(unavailability.start),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
