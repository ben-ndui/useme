import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/widgets/common/limit_reached_dialog.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Session creation/editing form
class SessionFormScreen extends StatefulWidget {
  final String? sessionId;

  const SessionFormScreen({super.key, this.sessionId});

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  SessionType _selectedType = SessionType.recording;
  List<Artist> _selectedArtists = [];
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  int _durationHours = 2;
  bool _isLoaded = false;
  Session? _existingSession;

  bool get isEditing => widget.sessionId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded && isEditing) {
      _loadSessionData();
      _isLoaded = true;
    }
  }

  void _loadSessionData() {
    final sessionState = context.read<SessionBloc>().state;
    if (sessionState is SessionsLoadedState) {
      final session = sessionState.sessions.where((s) => s.id == widget.sessionId).firstOrNull;
      if (session != null) {
        _existingSession = session;
        _selectedType = session.types.firstOrNull ?? SessionType.recording;
        _selectedDate = session.scheduledStart;
        _startTime = TimeOfDay(hour: session.scheduledStart.hour, minute: session.scheduledStart.minute);
        _durationHours = session.durationMinutes ~/ 60;
        _notesController.text = session.notes ?? '';

        // Charger les artistes sélectionnés
        final artistState = context.read<ArtistBloc>().state;
        _selectedArtists = artistState.artists
            .where((a) => session.artistIds.contains(a.id))
            .toList();

        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listener: (context, state) {
        if (state is SessionLimitReachedState) {
          LimitReachedDialog.show(
            context,
            limitType: 'sessions',
            currentCount: state.currentCount,
            maxAllowed: state.maxAllowed,
            tierId: state.tierId,
          );
        } else if (state is SessionCreatedState) {
          AppSnackBar.success(context, 'Session créée');
          context.pop();
        } else if (state is SessionUpdatedState) {
          AppSnackBar.success(context, 'Session modifiée');
          context.pop();
        } else if (state is SessionErrorState) {
          AppSnackBar.error(context, state.errorMessage ?? 'Erreur');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Modifier la session' : 'Nouvelle session'),
          actions: [
            if (isEditing)
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.trash, size: 18),
                onPressed: _showDeleteDialog,
              ),
          ],
        ),
        body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Session type
            _buildSectionTitle(context, 'Type de session'),
            const SizedBox(height: 8),
            _buildTypeSelector(context),
            const SizedBox(height: 24),

            // Artist selection (multi)
            _buildSectionTitle(context, 'Artistes'),
            const SizedBox(height: 8),
            _buildArtistsSelector(context),
            const SizedBox(height: 24),

            // Date & Time
            _buildSectionTitle(context, 'Date et heure'),
            const SizedBox(height: 8),
            _buildDateTimePickers(context),
            const SizedBox(height: 24),

            // Duration
            _buildSectionTitle(context, 'Durée'),
            const SizedBox(height: 8),
            _buildDurationSelector(context),
            const SizedBox(height: 24),

            // Notes
            _buildSectionTitle(context, 'Notes (optionnel)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Informations supplémentaires...',
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            FilledButton(
              onPressed: _submitForm,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(isEditing ? 'Enregistrer' : 'Créer la session'),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: SessionType.values.map((type) {
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

  Widget _buildArtistsSelector(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ArtistBloc, ArtistState>(
      builder: (context, state) {
        if (state.artists.isEmpty) {
          return OutlinedButton.icon(
            onPressed: () => context.push('/artists/add'),
            icon: const FaIcon(FontAwesomeIcons.userPlus, size: 16),
            label: const Text('Ajouter un artiste d\'abord'),
          );
        }

        // Artistes disponibles (non encore sélectionnés)
        final availableArtists = state.artists
            .where((a) => !_selectedArtists.any((s) => s.id == a.id))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chips des artistes sélectionnés
            if (_selectedArtists.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedArtists.map((artist) {
                  return Chip(
                    avatar: artist.photoUrl != null
                        ? CircleAvatar(backgroundImage: NetworkImage(artist.photoUrl!))
                        : CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              artist.displayName.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                    label: Text(artist.displayName),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _selectedArtists.removeWhere((a) => a.id == artist.id);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Dropdown pour ajouter un artiste
            if (availableArtists.isNotEmpty)
              DropdownButtonFormField<Artist>(
                initialValue: null,
                decoration: InputDecoration(
                  hintText: _selectedArtists.isEmpty
                      ? 'Sélectionner un artiste'
                      : 'Ajouter un autre artiste',
                  prefixIcon: const Icon(Icons.person_add),
                ),
                items: availableArtists.map((artist) {
                  return DropdownMenuItem(
                    value: artist,
                    child: Text(artist.displayName),
                  );
                }).toList(),
                onChanged: (artist) {
                  if (artist != null) {
                    setState(() {
                      _selectedArtists.add(artist);
                    });
                  }
                },
              )
            else if (_selectedArtists.isEmpty)
              Text(
                'Tous les artistes sont déjà sélectionnés',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDateTimePickers(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');

    return Row(
      children: [
        // Date picker
        Expanded(
          child: InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  FaIcon(FontAwesomeIcons.calendar, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dateFormat.format(_selectedDate),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Time picker
        InkWell(
          onTap: _pickTime,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.clock, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
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
            onSelected: (_) => setState(() => _durationHours = hours),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (time != null) {
      setState(() => _startTime = time);
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedArtists.isEmpty) {
      AppSnackBar.warning(context, 'Sélectionnez au moins un artiste');
      return;
    }

    // Get user subscription info
    final authState = context.read<AuthBloc>().state;
    String? subscriptionTierId;
    int? sessionsThisMonth;
    String studioId = '';

    if (authState is AuthAuthenticatedState) {
      final user = authState.user;
      if (user is AppUser) {
        studioId = user.uid;
        subscriptionTierId = user.subscriptionTierId;
        sessionsThisMonth = user.sessionsThisMonth;
      }
    }

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endDateTime = startDateTime.add(Duration(hours: _durationHours));

    final session = Session(
      id: widget.sessionId ?? '',
      studioId: studioId,
      artistIds: _selectedArtists.map((a) => a.id).toList(),
      artistNames: _selectedArtists.map((a) => a.name).toList(),
      types: [_selectedType],
      status: _existingSession?.status ?? SessionStatus.pending,
      scheduledStart: startDateTime,
      scheduledEnd: endDateTime,
      durationMinutes: _durationHours * 60,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      createdAt: _existingSession?.createdAt ?? DateTime.now(),
    );

    if (isEditing) {
      context.read<SessionBloc>().add(UpdateSessionEvent(session: session));
    } else {
      context.read<SessionBloc>().add(CreateSessionEvent(
            session: session,
            subscriptionTierId: subscriptionTierId,
            currentSessionCount: sessionsThisMonth,
          ));
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la session'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              context.read<SessionBloc>().add(
                    DeleteSessionEvent(sessionId: widget.sessionId!),
                  );
              Navigator.pop(context);
              context.pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
