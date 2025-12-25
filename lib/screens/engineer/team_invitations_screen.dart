import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/services/team_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Screen to display and manage team invitations for engineers
class TeamInvitationsScreen extends StatefulWidget {
  const TeamInvitationsScreen({super.key});

  @override
  State<TeamInvitationsScreen> createState() => _TeamInvitationsScreenState();
}

class _TeamInvitationsScreenState extends State<TeamInvitationsScreen> {
  final TeamService _teamService = TeamService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.teamInvitations)),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticatedState) {
            return const AppLoader();
          }

          final email = authState.user.email;
          if (email == null) {
            return Center(child: Text(l10n.noEmailConfigured));
          }

          return StreamBuilder<List<TeamInvitation>>(
            stream: _teamService.streamMyPendingInvitations(email),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppLoader();
              }

              final invitations = snapshot.data ?? [];

              if (invitations.isEmpty) {
                return _buildEmptyState(theme, l10n);
              }

              return _buildInvitationsList(context, invitations, authState.user.uid);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.envelopeOpen, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(l10n.noInvitations, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            l10n.noInvitationsDescription,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationsList(BuildContext context, List<TeamInvitation> invitations, String userId) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invitations.length,
      itemBuilder: (context, index) {
        return _InvitationCard(
          invitation: invitations[index],
          userId: userId,
          teamService: _teamService,
          isLoading: _isLoading,
          onLoadingChanged: (loading) => setState(() => _isLoading = loading),
        );
      },
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final TeamInvitation invitation;
  final String userId;
  final TeamService teamService;
  final bool isLoading;
  final ValueChanged<bool> onLoadingChanged;

  const _InvitationCard({
    required this.invitation,
    required this.userId,
    required this.teamService,
    required this.isLoading,
    required this.onLoadingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMd('fr_FR');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.buildingUser,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.studioName,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        l10n.invitationSentOn(dateFormat.format(invitation.createdAt)),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.teamInvitationMessage(invitation.studioName),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                FaIcon(FontAwesomeIcons.clock, size: 12, color: theme.colorScheme.outline),
                const SizedBox(width: 6),
                Text(
                  l10n.expiresOn(dateFormat.format(invitation.expiresAt)),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : () => _declineInvitation(context, l10n),
                    child: Text(l10n.decline),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: isLoading ? null : () => _acceptInvitation(context, l10n),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.accept),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptInvitation(BuildContext context, AppLocalizations l10n) async {
    onLoadingChanged(true);
    try {
      final result = await teamService.acceptInvitation(
        invitationId: invitation.id,
        userId: userId,
      );

      if (context.mounted) {
        if (result.code == 200) {
          AppSnackBar.success(context, l10n.invitationAccepted);
        } else {
          AppSnackBar.error(context, result.message ?? l10n.errorOccurred);
        }
      }
    } finally {
      onLoadingChanged(false);
    }
  }

  Future<void> _declineInvitation(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.declineInvitation),
        content: Text(l10n.declineInvitationConfirm(invitation.studioName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.decline),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    onLoadingChanged(true);
    try {
      final result = await teamService.declineInvitation(invitation.id);

      if (context.mounted) {
        if (result.code == 200) {
          AppSnackBar.info(context, l10n.invitationDeclined);
        } else {
          AppSnackBar.error(context, result.message ?? l10n.errorOccurred);
        }
      }
    } finally {
      onLoadingChanged(false);
    }
  }
}
