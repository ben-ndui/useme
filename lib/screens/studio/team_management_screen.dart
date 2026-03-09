import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/services/team_service.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/studio/team/team_exports.dart';

/// Screen de gestion de l'équipe (ingénieurs)
class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  final TeamService _teamService = TeamService();
  String? _studioId;
  String? _studioName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      final user = authState.user as AppUser;
      _studioId = user.uid;
      _studioName = user.studioDisplayName;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_studioId == null) {
      return const AppLoader.fullScreen();
    }

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.team)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(context, l10n.teamMembers),
              const SizedBox(height: 8),
              _buildTeamMembersList(),
              const SizedBox(height: 24),
              _buildSectionHeader(context, l10n.pendingInvitations),
              const SizedBox(height: 8),
              _buildPendingInvitations(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMemberSheet,
        icon: const FaIcon(FontAwesomeIcons.userPlus, size: 18),
        label: Text(l10n.add),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
    );
  }

  Widget _buildTeamMembersList() {
    return StreamBuilder<List<AppUser>>(
      stream: _teamService.streamTeamMembers(_studioId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoader.compact();
        }

        final members = snapshot.data ?? [];

        if (members.isEmpty) {
          final l10n = AppLocalizations.of(context)!;
          return _buildEmptyState(
            icon: FontAwesomeIcons.users,
            title: l10n.noMember,
            subtitle: l10n.addEngineersToTeam,
          );
        }

        return Column(
          children: members.map((member) => TeamMemberCard(
            member: member,
            onOptionsPressed: () => _showMemberOptions(member),
          )).toList(),
        );
      },
    );
  }

  Widget _buildPendingInvitations() {
    return StreamBuilder<List<TeamInvitation>>(
      stream: _teamService.streamPendingInvitations(_studioId!),
      builder: (context, snapshot) {
        final invitations = snapshot.data ?? [];

        if (invitations.isEmpty) {
          final l10n = AppLocalizations.of(context)!;
          return _buildEmptyState(
            icon: FontAwesomeIcons.envelopeOpenText,
            title: l10n.noInvitation,
            subtitle: l10n.pendingInvitationsHere,
          );
        }

        return Column(
          children: invitations.map((inv) => TeamInvitationCard(
            invitation: inv,
            onCancel: () => _cancelInvitation(inv),
          )).toList(),
        );
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          FaIcon(icon, size: 32, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }

  void _showAddMemberSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddTeamMemberSheet(
        studioId: _studioId!,
        studioName: _studioName ?? 'Studio',
        teamService: _teamService,
      ),
    );
  }

  void _showMemberOptions(AppUser member) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.userMinus, size: 18),
              title: Text(l10n.removeFromTeam),
              onTap: () {
                Navigator.pop(context);
                _confirmRemoveMember(member);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveMember(AppUser member) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.removeMemberConfirm),
        content: Text(l10n.memberNoAccessAnymore(member.fullName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _teamService.removeFromTeam(member.uid);
              if (mounted) {
                AppSnackBar.success(context, l10n.memberRemoved);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelInvitation(TeamInvitation invitation) async {
    await _teamService.cancelInvitation(invitation.id);
    if (mounted) {
      AppSnackBar.success(context, AppLocalizations.of(context)!.invitationCancelled);
    }
  }
}
