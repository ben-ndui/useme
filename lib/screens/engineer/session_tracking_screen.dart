import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Session tracking screen - For engineer to check-in/out and add notes
class SessionTrackingScreen extends StatefulWidget {
  final String sessionId;

  const SessionTrackingScreen({super.key, required this.sessionId});

  @override
  State<SessionTrackingScreen> createState() => _SessionTrackingScreenState();
}

class _SessionTrackingScreenState extends State<SessionTrackingScreen> {
  final _notesController = TextEditingController();
  bool _isCheckedIn = false;
  DateTime? _checkInTime;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For now, we'll show a mock session. In production, this would load from BLoC
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi session'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.ellipsisVertical, size: 18),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSessionInfo(context),
          const SizedBox(height: 24),
          _buildCheckInSection(context),
          const SizedBox(height: 24),
          _buildNotesSection(context),
          const SizedBox(height: 24),
          _buildPhotosSection(context),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildSessionInfo(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');

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
                        'Artiste Demo',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text('Recording', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(context, FontAwesomeIcons.calendar, dateFormat.format(DateTime.now())),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(context, FontAwesomeIcons.clock, '10:00 - 14:00'),
                ),
                Expanded(
                  child: _buildInfoRow(context, FontAwesomeIcons.hourglass, '4h prévues'),
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
        Text(text, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildCheckInSection(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm', 'fr_FR');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pointage', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (!_isCheckedIn)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _checkIn,
                  icon: const FaIcon(FontAwesomeIcons.rightToBracket, size: 16),
                  label: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Pointer l\'arrivée'),
                  ),
                ),
              )
            else
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        FaIcon(FontAwesomeIcons.circleCheck, size: 20, color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Arrivée pointée',
                                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green.shade700),
                              ),
                              Text(
                                _checkInTime != null ? timeFormat.format(_checkInTime!) : '',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _checkOut,
                      icon: const FaIcon(FontAwesomeIcons.rightFromBracket, size: 16),
                      label: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Pointer le départ'),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notes de session', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Ajouter des notes sur la session...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Photos', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Add photo
              },
              icon: const FaIcon(FontAwesomeIcons.camera, size: 16),
              label: const Text('Ajouter une photo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: FilledButton(
          onPressed: _saveAndClose,
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Enregistrer'),
          ),
        ),
      ),
    );
  }

  void _checkIn() {
    setState(() {
      _isCheckedIn = true;
      _checkInTime = DateTime.now();
    });
    AppSnackBar.success(context, 'Arrivée pointée !');
  }

  void _checkOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminer la session ?'),
        content: const Text('Voulez-vous pointer votre départ et terminer cette session ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _saveAndClose();
            },
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }

  void _saveAndClose() {
    // TODO: Save session data
    context.pop();
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.message, size: 18),
              title: const Text('Contacter l\'artiste'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.circleExclamation, size: 18),
              title: const Text('Signaler un problème'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
