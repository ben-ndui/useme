import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/studio_room.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/limit_reached_dialog.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Screen for creating/editing a studio room
class RoomFormScreen extends StatefulWidget {
  final String? roomId;

  const RoomFormScreen({super.key, this.roomId});

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _equipmentController = TextEditingController();

  bool _requiresEngineer = true;
  bool _isActive = true;
  bool _isLoading = false;
  StudioRoom? _existingRoom;

  bool get isEditing => widget.roomId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) _loadRoom();
  }

  void _loadRoom() {
    final state = context.read<StudioRoomBloc>().state;
    final room = state.rooms.where((r) => r.id == widget.roomId).firstOrNull;
    if (room != null) {
      _existingRoom = room;
      _nameController.text = room.name;
      _descriptionController.text = room.description ?? '';
      _hourlyRateController.text = room.hourlyRate?.toStringAsFixed(0) ?? '';
      _equipmentController.text = room.equipmentList.join(', ');
      _requiresEngineer = room.requiresEngineer;
      _isActive = room.isActive;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _hourlyRateController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocListener<StudioRoomBloc, StudioRoomState>(
      listener: (context, state) {
        if (state.status == StudioRoomStatus.limitReached) {
          LimitReachedDialog.show(
            context,
            limitType: 'salles',
            currentCount: state.currentCount ?? 0,
            maxAllowed: state.maxAllowed ?? 0,
            tierId: state.tierId ?? 'free',
          );
          setState(() => _isLoading = false);
        } else if (state.status == StudioRoomStatus.loaded && _isLoading) {
          AppSnackBar.success(context, isEditing ? 'Salle modifiée' : 'Salle créée');
          context.pop();
        } else if (state.status == StudioRoomStatus.error) {
          AppSnackBar.error(context, state.errorMessage ?? 'Erreur');
          setState(() => _isLoading = false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? l10n.editRoom : l10n.addRoom),
          actions: [
            if (isEditing)
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.trash, size: 18),
                onPressed: () => _confirmDelete(l10n),
              ),
          ],
        ),
        body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.roomName,
                hintText: l10n.roomNameHint,
                prefixIcon: const Icon(Icons.meeting_room),
              ),
              validator: (v) => v?.isEmpty == true ? l10n.fieldRequired : null,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.description,
                hintText: l10n.roomDescriptionHint,
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Hourly rate
            TextFormField(
              controller: _hourlyRateController,
              decoration: InputDecoration(
                labelText: l10n.hourlyRate,
                hintText: '50',
                prefixIcon: const Icon(Icons.euro),
                suffixText: '€/h',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Access type
            Text(l10n.accessType, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildAccessTypeSelector(theme, l10n),
            const SizedBox(height: 24),

            // Equipment
            TextFormField(
              controller: _equipmentController,
              decoration: InputDecoration(
                labelText: l10n.equipment,
                hintText: l10n.equipmentHint,
                prefixIcon: const Icon(Icons.speaker),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Active toggle
            SwitchListTile(
              title: Text(l10n.roomActive),
              subtitle: Text(_isActive ? l10n.roomVisibleForBooking : l10n.roomHiddenForBooking),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
            const SizedBox(height: 32),

            // Save button
            FilledButton(
              onPressed: _isLoading ? null : _save,
              style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isEditing ? l10n.save : l10n.create),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildAccessTypeSelector(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildAccessOption(
            theme,
            icon: FontAwesomeIcons.headphones,
            title: l10n.withEngineer,
            subtitle: l10n.withEngineerDesc,
            isSelected: _requiresEngineer,
            onTap: () => setState(() => _requiresEngineer = true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAccessOption(
            theme,
            icon: FontAwesomeIcons.doorOpen,
            title: l10n.selfService,
            subtitle: l10n.selfServiceDesc,
            isSelected: !_requiresEngineer,
            color: Colors.green,
            onTap: () => setState(() => _requiresEngineer = false),
          ),
        ),
      ],
    );
  }

  Widget _buildAccessOption(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final selectedColor = color ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withValues(alpha: 0.1) : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? selectedColor : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            FaIcon(icon, size: 24, color: isSelected ? selectedColor : theme.colorScheme.outline),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? selectedColor : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    // Get subscription info
    String? subscriptionTierId;
    if (authState.user is AppUser) {
      subscriptionTierId = (authState.user as AppUser).subscriptionTierId;
    }

    // Get current rooms count from bloc state
    final roomState = context.read<StudioRoomBloc>().state;
    final currentRoomCount = roomState.rooms.length;

    final equipmentList = _equipmentController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final room = StudioRoom(
      id: _existingRoom?.id ?? '',
      studioId: authState.user.uid,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      hourlyRate: double.tryParse(_hourlyRateController.text),
      requiresEngineer: _requiresEngineer,
      equipmentList: equipmentList,
      isActive: _isActive,
      createdAt: _existingRoom?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (isEditing) {
      context.read<StudioRoomBloc>().add(UpdateRoomEvent(room: room));
    } else {
      context.read<StudioRoomBloc>().add(CreateRoomEvent(
            room: room,
            subscriptionTierId: subscriptionTierId,
            currentRoomCount: currentRoomCount,
          ));
    }
  }

  void _confirmDelete(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteRoom),
        content: Text(l10n.deleteRoomConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<StudioRoomBloc>().add(DeleteRoomEvent(roomId: widget.roomId!));
              context.pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
