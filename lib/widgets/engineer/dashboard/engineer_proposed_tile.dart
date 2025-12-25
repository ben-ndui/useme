import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/services/engineer_proposal_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// A proposed session tile for engineer dashboard
class EngineerProposedTile extends StatefulWidget {
  final Session session;
  final String engineerId;
  final AppUser engineer;
  final String locale;

  const EngineerProposedTile({
    super.key,
    required this.session,
    required this.engineerId,
    required this.engineer,
    required this.locale,
  });

  @override
  State<EngineerProposedTile> createState() => _EngineerProposedTileState();
}

class _EngineerProposedTileState extends State<EngineerProposedTile> {
  bool _isLoading = false;
  final _proposalService = EngineerProposalService();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('EEE d MMM', widget.locale);
    final timeFormat = DateFormat('HH:mm', widget.locale);

    final hasOtherEngineer = widget.session.hasEngineer &&
        !widget.session.isEngineerAssigned(widget.engineerId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(_getTypeIcon(widget.session.type), size: 18, color: Colors.purple),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.session.artistName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        FaIcon(FontAwesomeIcons.calendar, size: 10, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          '${dateFormat.format(widget.session.scheduledStart)} • ${timeFormat.format(widget.session.scheduledStart)}',
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasOtherEngineer ? l10n.sessionTaken : l10n.sessionProposedToYou,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.purple),
                ),
              ),
            ],
          ),
          if (hasOtherEngineer) ...[
            const SizedBox(height: 10),
            Text(
              l10n.sessionTakenDesc,
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 14),
          if (_isLoading)
            const Center(
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            hasOtherEngineer ? _buildJoinButton(l10n) : _buildActionButtons(l10n),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _handleDecline(l10n),
            icon: const FaIcon(FontAwesomeIcons.xmark, size: 14),
            label: Text(l10n.declineProposal),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: () => _handleAccept(l10n),
            icon: const FaIcon(FontAwesomeIcons.check, size: 14, color: Colors.white),
            label: Text(l10n.acceptProposal),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJoinButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _handleJoin(l10n),
        icon: const FaIcon(FontAwesomeIcons.userPlus, size: 14, color: Colors.white),
        label: Text(l10n.requestToJoin),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.purple,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Future<void> _handleAccept(AppLocalizations l10n) async {
    setState(() => _isLoading = true);
    try {
      await _proposalService.acceptProposal(
        sessionId: widget.session.id,
        engineer: widget.engineer,
        session: widget.session,
        studioName: '',
      );
      if (!mounted) return;
      AppSnackBar.success(context, l10n.proposalAccepted);
      _refreshSessions();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, 'Erreur: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDecline(AppLocalizations l10n) async {
    setState(() => _isLoading = true);
    try {
      await _proposalService.declineProposal(
        sessionId: widget.session.id,
        engineerId: widget.engineerId,
      );
      if (!mounted) return;
      AppSnackBar.info(context, l10n.proposalDeclined);
      _refreshSessions();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, 'Erreur: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleJoin(AppLocalizations l10n) async {
    setState(() => _isLoading = true);
    try {
      await _proposalService.joinAsCoEngineer(
        sessionId: widget.session.id,
        engineer: widget.engineer,
        session: widget.session,
      );
      if (!mounted) return;
      AppSnackBar.success(context, l10n.joinedAsCoEngineer);
      _refreshSessions();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, 'Erreur: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _refreshSessions() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      context.read<SessionBloc>().add(LoadEngineerSessionsEvent(engineerId: authState.user.uid));
    }
  }

  IconData _getTypeIcon(SessionType type) {
    return switch (type) {
      SessionType.recording => FontAwesomeIcons.microphone,
      SessionType.mix || SessionType.mixing => FontAwesomeIcons.sliders,
      SessionType.mastering => FontAwesomeIcons.compactDisc,
      SessionType.editing => FontAwesomeIcons.scissors,
      _ => FontAwesomeIcons.music,
    };
  }
}
