import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/engineer/session_tracking_checkin.dart';
import 'package:useme/widgets/engineer/session_tracking_photos.dart';

/// Body content of the session tracking screen
class SessionTrackingBody extends StatelessWidget {
  final Session session;
  final TextEditingController notesController;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final VoidCallback onAddPhoto;

  const SessionTrackingBody({
    super.key,
    required this.session,
    required this.notesController,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onAddPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Prefill notes from session if controller is empty
    if (notesController.text.isEmpty && session.intervention.notes != null) {
      notesController.text = session.intervention.notes!;
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Responsive.maxFormWidth),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSessionInfo(context),
            const SizedBox(height: 24),
            SessionTrackingCheckin(
              intervention: session.intervention,
              displayStatus: session.displayStatus,
              onCheckIn: onCheckIn,
              onCheckOut: onCheckOut,
            ),
            const SizedBox(height: 24),
            _buildNotesSection(context, l10n),
            const SizedBox(height: 24),
            SessionTrackingPhotos(
              photos: session.intervention.photos,
              onAddPhoto: onAddPhoto,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    final timeFormat = DateFormat('HH:mm', 'fr_FR');
    final hours = session.durationMinutes ~/ 60;

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
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: FaIcon(FontAwesomeIcons.microphone, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.artistName,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        session.typeLabel,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              FontAwesomeIcons.calendar,
              dateFormat.format(session.scheduledStart),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    context,
                    FontAwesomeIcons.clock,
                    '${timeFormat.format(session.scheduledStart)} - '
                        '${timeFormat.format(session.scheduledEnd)}',
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    context,
                    FontAwesomeIcons.hourglass,
                    l10n.hoursPlanned(hours),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        FaIcon(icon, size: 14, color: theme.colorScheme.outline),
        const SizedBox(width: 8),
        Flexible(child: Text(text, style: theme.textTheme.bodySmall)),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.sessionNotes,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: l10n.addSessionNotes,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
