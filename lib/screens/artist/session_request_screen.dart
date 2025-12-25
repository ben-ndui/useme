import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/services/services_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/artist/availability_picker.dart';
import 'package:useme/widgets/artist/engineer_selector_bottom_sheet.dart';
import 'package:useme/widgets/artist/session_request/session_request_exports.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Session request form for artists to request new sessions
class SessionRequestScreen extends StatefulWidget {
  final String? studioId;
  final String? studioName;

  const SessionRequestScreen({super.key, this.studioId, this.studioName});

  @override
  State<SessionRequestScreen> createState() => _SessionRequestScreenState();
}

class _SessionRequestScreenState extends State<SessionRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _sessionService = SessionService();
  final _roomService = StudioRoomService();

  final Set<SessionType> _selectedTypes = {SessionType.recording};
  DateTime? _selectedDate;
  EnhancedTimeSlot? _selectedSlot;
  AvailableEngineer? _selectedEngineer;
  StudioRoom? _selectedRoom;
  List<StudioRoom> _availableRooms = [];
  bool _loadingRooms = false;
  int _durationHours = 2;
  bool _isSubmitting = false;
  WorkingHours? _studioWorkingHours;

  @override
  void initState() {
    super.initState();
    if (widget.studioId != null) {
      _loadRooms();
      _loadStudioWorkingHours();
    }
  }

  Future<void> _loadStudioWorkingHours() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.studioId).get();
      if (doc.exists) {
        final data = doc.data();
        final studioProfileData = data?['studioProfile'] as Map<String, dynamic>?;
        if (studioProfileData != null && studioProfileData['workingHours'] != null) {
          setState(() {
            _studioWorkingHours = WorkingHours.fromMap(studioProfileData['workingHours'] as Map<String, dynamic>);
          });
        }
      }
    } catch (e) {
      debugPrint('Erreur chargement horaires studio: $e');
    }
  }

  Future<void> _loadRooms() async {
    setState(() => _loadingRooms = true);
    try {
      final rooms = await _roomService.getActiveRoomsByStudio(widget.studioId!);
      setState(() {
        _availableRooms = rooms;
        _loadingRooms = false;
      });
    } catch (e) {
      setState(() => _loadingRooms = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studioName != null ? l10n.sessionAt(widget.studioName!) : l10n.sessionRequest),
      ),
      body: widget.studioId == null
          ? _buildNoStudioState(theme, l10n)
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildInfoCard(theme, l10n),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, l10n.sessionType),
                  const SizedBox(height: 8),
                  SessionTypeSelector(
                    selectedTypes: _selectedTypes,
                    onTypesChanged: (types) => setState(() => _selectedTypes
                      ..clear()
                      ..addAll(types)),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, l10n.sessionDuration),
                  const SizedBox(height: 8),
                  _buildDurationSelector(context),
                  const SizedBox(height: 24),
                  if (_availableRooms.isNotEmpty) ...[
                    _buildSectionTitle(context, l10n.selectRoom),
                    const SizedBox(height: 8),
                    SessionRoomSelector(
                      availableRooms: _availableRooms,
                      selectedRoom: _selectedRoom,
                      isLoading: _loadingRooms,
                      onRoomSelected: (room) => setState(() {
                        _selectedRoom = room;
                        if (room != null && !room.requiresEngineer) _selectedEngineer = null;
                      }),
                    ),
                    const SizedBox(height: 24),
                  ],
                  _buildSectionTitle(context, l10n.chooseSlot),
                  const SizedBox(height: 8),
                  AvailabilityPicker(
                    studioId: widget.studioId!,
                    durationMinutes: _durationHours * 60,
                    workingHours: _studioWorkingHours,
                    onSlotSelected: (date, slot) => setState(() {
                      _selectedDate = date;
                      _selectedSlot = slot;
                      _selectedEngineer = null;
                    }),
                  ),
                  const SizedBox(height: 24),
                  if (_selectedSlot != null &&
                      _selectedSlot!.availableEngineers.isNotEmpty &&
                      (_selectedRoom == null || _selectedRoom!.requiresEngineer)) ...[
                    _buildSectionTitle(context, l10n.engineerPreference),
                    const SizedBox(height: 8),
                    SessionEngineerSelector(
                      selectedEngineer: _selectedEngineer,
                      availableCount: _selectedSlot!.availableCount,
                      onTap: () => _showEngineerSelector(context),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (_selectedRoom != null && !_selectedRoom!.requiresEngineer) ...[
                    const SelfServiceInfoCard(),
                    const SizedBox(height: 24),
                  ],
                  _buildSectionTitle(context, l10n.notesOptional),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(hintText: l10n.describeProject),
                  ),
                  const SizedBox(height: 32),
                  if (_selectedSlot != null && _selectedDate != null)
                    SessionRequestSummary(
                      date: _selectedDate!,
                      slotStart: _selectedSlot!.start,
                      slotEnd: _selectedSlot!.end,
                      selectedRoom: _selectedRoom,
                      selectedEngineer: _selectedEngineer,
                    ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _canSubmit ? () => _submitRequest(l10n) : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(l10n.sendRequest),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildNoStudioState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.buildingUser, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(l10n.noStudioSelected, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              l10n.selectStudioFirst,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 14),
              label: Text(l10n.back),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, AppLocalizations l10n) {
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
          Expanded(child: Text(l10n.slotInfoText, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600));
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
            onSelected: (_) => setState(() {
              _durationHours = hours;
              _selectedSlot = null;
              _selectedEngineer = null;
            }),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _showEngineerSelector(BuildContext context) async {
    if (_selectedSlot == null) return;
    final selected = await EngineerSelectorBottomSheet.show(
      context,
      _selectedSlot!.availableEngineers,
      selectedEngineer: _selectedEngineer,
    );
    if (mounted) setState(() => _selectedEngineer = selected);
  }

  bool get _canSubmit => _selectedSlot != null && !_isSubmitting;

  Future<void> _submitRequest(AppLocalizations l10n) async {
    if (!_canSubmit) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    setState(() => _isSubmitting = true);

    try {
      final session = Session(
        id: '',
        studioId: widget.studioId!,
        roomId: _selectedRoom?.id,
        roomName: _selectedRoom?.name,
        artistIds: [authState.user.uid],
        artistNames: [authState.user.name ?? 'Artiste'],
        types: _selectedTypes.toList(),
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
          AppSnackBar.success(context, l10n.requestSent);
          context.pop();
        } else {
          AppSnackBar.error(context, response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
