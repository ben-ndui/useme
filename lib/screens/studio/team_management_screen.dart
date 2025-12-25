import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/services/team_service.dart';
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Équipe')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'Membres de l\'équipe'),
          const SizedBox(height: 8),
          _buildTeamMembersList(),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Invitations en attente'),
          const SizedBox(height: 8),
          _buildPendingInvitations(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMemberSheet,
        icon: const FaIcon(FontAwesomeIcons.userPlus, size: 18),
        label: const Text('Ajouter'),
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
          return _buildEmptyState(
            icon: FontAwesomeIcons.users,
            title: 'Aucun membre',
            subtitle: 'Ajoutez des ingénieurs à votre équipe',
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
          return _buildEmptyState(
            icon: FontAwesomeIcons.envelopeOpenText,
            title: 'Aucune invitation',
            subtitle: 'Les invitations en attente apparaîtront ici',
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
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.userMinus, size: 18),
              title: const Text('Retirer de l\'équipe'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer ce membre ?'),
        content: Text('${member.fullName} ne pourra plus accéder aux sessions du studio.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _teamService.removeFromTeam(member.uid);
              if (mounted) {
                AppSnackBar.success(context, 'Membre retiré');
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelInvitation(TeamInvitation invitation) async {
    await _teamService.cancelInvitation(invitation.id);
    if (mounted) {
      AppSnackBar.success(context, 'Invitation annulée');
    }
  }
}
