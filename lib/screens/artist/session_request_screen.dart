import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/services/services_exports.dart';
import 'package:useme/widgets/artist/availability_picker.dart';
import 'package:useme/widgets/artist/engineer_selector_bottom_sheet.dart';

/// Session request form for artists to request new sessions
class SessionRequestScreen extends StatefulWidget {
  final String? studioId;
  final String? studioName;

  const SessionRequestScreen({
    super.key,
    this.studioId,
    this.studioName,
  });

  @override
  State<SessionRequestScreen> createState() => _SessionRequestScreenState();
}

class _SessionRequestScreenState extends State<SessionRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _sessionService = SessionService();

  SessionType _selectedType = SessionType.recording;
  DateTime? _selectedDate;
  EnhancedTimeSlot? _selectedSlot;
  AvailableEngineer? _selectedEngineer;
  int _durationHours = 2;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studioName != null
            ? 'Session chez ${widget.studioName}'
            : 'Demande de session'),
      ),
      body: widget.studioId == null
          ? _buildNoStudioState(theme)
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildInfoCard(theme),
                  const SizedBox(height: 24),

                  // Session type
                  _buildSectionTitle(context, 'Type de session'),
                  const SizedBox(height: 8),
                  _buildTypeSelector(context),
                  const SizedBox(height: 24),

                  // Duration
                  _buildSectionTitle(context, 'Durée de la session'),
                  const SizedBox(height: 8),
                  _buildDurationSelector(context),
                  const SizedBox(height: 24),

                  // Availability picker
                  _buildSectionTitle(context, 'Choisissez votre créneau'),
                  const SizedBox(height: 8),
                  AvailabilityPicker(
                    studioId: widget.studioId!,
                    durationMinutes: _durationHours * 60,
                    onSlotSelected: (date, slot) {
                      setState(() {
                        _selectedDate = date;
                        _selectedSlot = slot;
                        _selectedEngineer = null; // Reset engineer on slot change
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Engineer selection (only if slot selected)
                  if (_selectedSlot != null && _selectedSlot!.availableEngineers.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Préférence d\'ingénieur'),
                    const SizedBox(height: 8),
                    _buildEngineerSelector(theme),
                    const SizedBox(height: 24),
                  ],

                  // Notes
                  _buildSectionTitle(context, 'Notes (optionnel)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Décrivez votre projet, vos besoins...',
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Selected summary
                  if (_selectedSlot != null) _buildSelectedSummary(theme),
                  const SizedBox(height: 16),

                  // Submit button
                  FilledButton(
                    onPressed: _canSubmit ? _submitRequest : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Envoyer la demande'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildNoStudioState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.buildingUser, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('Aucun studio sélectionné', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Sélectionnez d\'abord un studio pour voir ses disponibilités.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 14),
              label: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          FaIcon(FontAwesomeIcons.circleInfo, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Les créneaux verts ont plus d\'ingénieurs disponibles. Vous pouvez aussi choisir votre ingénieur préféré.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        SessionType.recording,
        SessionType.mix,
        SessionType.mastering,
        SessionType.editing
      ].map((type) {
        final isSelected = _selectedType == type;
        return ChoiceChip(
          label: Text(type.label),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedType = type),
          avatar: isSelected ? null : FaIcon(_getTypeIcon(type), size: 14),
        );
      }).toList(),
    );
  }

  Widget _buildDurationSelector(BuildContext context) {
    return Wrap(
      children: [1, 2, 3, 4, 6, 8].map((hours) {
        final isSelected = _durationHours == hours;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text('${hours}h'),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _durationHours = hours;
                _selectedSlot = null;
                _selectedEngineer = null;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEngineerSelector(ThemeData theme) {
    return InkWell(
      onTap: () => _showEngineerSelector(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: _selectedEngineer != null
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _selectedEngineer != null
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(22),
              ),
              child: _selectedEngineer != null && _selectedEngineer!.user.photoURL != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.network(
                        _selectedEngineer!.user.photoURL!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            _selectedEngineer!.user.name?[0].toUpperCase() ?? 'I',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: FaIcon(
                        _selectedEngineer != null
                            ? FontAwesomeIcons.userCheck
                            : FontAwesomeIcons.shuffle,
                        size: 18,
                        color: _selectedEngineer != null
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedEngineer != null
                        ? (_selectedEngineer!.user.name ?? 'Ingénieur')
                        : 'Pas de préférence',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    _selectedEngineer != null
                        ? 'Ingénieur sélectionné'
                        : 'Laisser le studio choisir',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ),
            // Badge count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(FontAwesomeIcons.userGear, size: 10, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    '${_selectedSlot!.availableCount} dispo',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FaIcon(FontAwesomeIcons.chevronRight, size: 14, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }

  Future<void> _showEngineerSelector(BuildContext context) async {
    if (_selectedSlot == null) return;

    final selected = await EngineerSelectorBottomSheet.show(
      context,
      _selectedSlot!.availableEngineers,
      selectedEngineer: _selectedEngineer,
    );

    if (mounted) {
      setState(() => _selectedEngineer = selected);
    }
  }

  Widget _buildSelectedSummary(ThemeData theme) {
    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    final timeFormat = DateFormat('HH:mm', 'fr_FR');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.check, size: 16, color: Colors.green),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Récapitulatif',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_selectedDate != null)
                      Text(
                        dateFormat.format(_selectedDate!),
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.green.shade700),
                      ),
                    Text(
                      '${timeFormat.format(_selectedSlot!.start)} - ${timeFormat.format(_selectedSlot!.end)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.green.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_selectedEngineer != null) ...[
            const Divider(height: 24),
            Row(
              children: [
                FaIcon(FontAwesomeIcons.userCheck, size: 14, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(
                  'Ingénieur : ${_selectedEngineer!.user.name ?? 'Non spécifié'}',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.green.shade600),
                ),
              ],
            ),
          ],
        ],
      ),
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

  bool get _canSubmit => _selectedSlot != null && !_isSubmitting;

  Future<void> _submitRequest() async {
    if (!_canSubmit) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    setState(() => _isSubmitting = true);

    try {
      final session = Session(
        id: '',
        studioId: widget.studioId!,
        artistIds: [authState.user.uid],
        artistNames: [authState.user.name ?? 'Artiste'],
        type: _selectedType,
        status: SessionStatus.pending,
        scheduledStart: _selectedSlot!.start,
        scheduledEnd: _selectedSlot!.end,
        durationMinutes: _durationHours * 60,
        engineerId: _selectedEngineer?.user.uid,
        engineerName: _selectedEngineer?.user.name,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final response = await _sessionService.createSession(session);

      if (mounted) {
        if (response.code == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Demande envoyée ! Le studio vous répondra bientôt.'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
