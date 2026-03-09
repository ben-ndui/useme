import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/core/blocs/session/session_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/services/session_photo_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';
import 'package:useme/widgets/engineer/session_tracking_body.dart';

/// Session tracking screen - For engineer to check-in/out and add notes
class SessionTrackingScreen extends StatefulWidget {
  final String sessionId;

  const SessionTrackingScreen({super.key, required this.sessionId});

  @override
  State<SessionTrackingScreen> createState() => _SessionTrackingScreenState();
}

class _SessionTrackingScreenState extends State<SessionTrackingScreen> {
  final _notesController = TextEditingController();
  final _photoService = SessionPhotoService();

  @override
  void initState() {
    super.initState();
    context.read<SessionBloc>().add(
          LoadSessionByIdEvent(sessionId: widget.sessionId),
        );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionTracking),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.ellipsisVertical, size: 18),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: BlocConsumer<SessionBloc, SessionState>(
        listener: _onBlocStateChange,
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final session = state.selectedSession;
          if (session == null) {
            return Center(child: Text(l10n.sessionNotFound));
          }
          return SessionTrackingBody(
            session: session,
            notesController: _notesController,
            onCheckIn: () => _checkIn(session),
            onCheckOut: () => _checkOut(session),
            onAddPhoto: () => _addPhoto(session),
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  void _onBlocStateChange(BuildContext context, SessionState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state is SessionNotesUpdatedState) {
      AppSnackBar.success(context, l10n.notesSaved);
    } else if (state is SessionPhotoAddedState) {
      AppSnackBar.success(context, l10n.photoAdded);
      context.read<SessionBloc>().add(
            LoadSessionByIdEvent(sessionId: widget.sessionId),
          );
    } else if (state is SessionStatusUpdatedState) {
      AppSnackBar.success(context, l10n.arrivalCheckedSuccess);
      context.read<SessionBloc>().add(
            LoadSessionByIdEvent(sessionId: widget.sessionId),
          );
    } else if (state is SessionErrorState && state.errorMessage != null) {
      AppSnackBar.error(context, state.errorMessage!);
    }
  }

  void _checkIn(Session session) =>
      context.read<SessionBloc>().add(CheckinSessionEvent(sessionId: session.id));

  void _checkOut(Session session) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.endSession),
        content: Text(l10n.endSessionConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SessionBloc>().add(CheckoutSessionEvent(sessionId: session.id));
            },
            child: Text(l10n.finish),
          ),
        ],
      ),
    );
  }

  Future<void> _addPhoto(Session session) async {
    final l10n = AppLocalizations.of(context)!;
    final response = await _photoService.pickAndUploadPhoto(
      context: context,
      sessionId: session.id,
    );
    if (!mounted) return;
    if (response.code == 200 && response.data != null) {
      context.read<SessionBloc>().add(
            AddSessionPhotoEvent(
              sessionId: session.id,
              photoUrl: response.data!,
            ),
          );
    } else if (response.code == 500) {
      AppSnackBar.error(context, l10n.photoUploadError);
    }
  }

  void _saveAndClose() {
    final state = context.read<SessionBloc>().state;
    final session = state.selectedSession;
    if (session != null && _notesController.text.isNotEmpty) {
      context.read<SessionBloc>().add(
            UpdateSessionNotesEvent(
              sessionId: session.id,
              notes: _notesController.text,
            ),
          );
    }
    context.pop();
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: FilledButton(
          onPressed: _saveAndClose,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.message, size: 18),
            title: Text(l10n.contactArtist),
            onTap: () => Navigator.pop(ctx),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.circleExclamation, size: 18),
            title: Text(l10n.reportProblemAction),
            onTap: () => Navigator.pop(ctx),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
