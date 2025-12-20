import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/services/team_service.dart';

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
    final theme = Theme.of(context);

    if (_studioId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Équipe')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: Membres actuels
          _buildSectionHeader(context, 'Membres de l\'équipe'),
          const SizedBox(height: 8),
          _buildTeamMembersList(),
          const SizedBox(height: 24),

          // Section: Invitations en attente
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
          return const Center(child: CircularProgressIndicator());
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
          children: members.map((member) => _buildMemberCard(member)).toList(),
        );
      },
    );
  }

  Widget _buildMemberCard(AppUser member) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: member.photoURL != null ? NetworkImage(member.photoURL!) : null,
          child: member.photoURL == null
              ? Text(
                  (member.displayName ?? member.email ?? 'U')[0].toUpperCase(),
                  style: TextStyle(color: theme.colorScheme.primary),
                )
              : null,
        ),
        title: Text(
          member.fullName,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(member.email ?? '', style: theme.textTheme.bodySmall),
        trailing: IconButton(
          icon: FaIcon(FontAwesomeIcons.ellipsisVertical,
              size: 16, color: theme.colorScheme.outline),
          onPressed: () => _showMemberOptions(member),
        ),
      ),
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
          children: invitations.map((inv) => _buildInvitationCard(inv)).toList(),
        );
      },
    );
  }

  Widget _buildInvitationCard(TeamInvitation invitation) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.clock, size: 16, color: Colors.orange),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invitation.name ?? invitation.email,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    invitation.email,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          invitation.code,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.copy, size: 12),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: invitation.code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Code copié')),
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: FaIcon(FontAwesomeIcons.xmark, size: 16, color: theme.colorScheme.error),
              onPressed: () => _cancelInvitation(invitation),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
      builder: (context) => _AddMemberSheet(
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _teamService.removeFromTeam(member.uid);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Membre retiré')),
                );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitation annulée')),
      );
    }
  }
}

/// Bottom sheet pour ajouter un membre
class _AddMemberSheet extends StatefulWidget {
  final String studioId;
  final String studioName;
  final TeamService teamService;

  const _AddMemberSheet({
    required this.studioId,
    required this.studioName,
    required this.teamService,
  });

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  AppUser? _foundUser;
  bool _userNotFound = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Ajouter un membre',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Recherchez par email ou invitez un nouvel ingénieur',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 24),

          // Email field
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              suffixIcon: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchUser,
                    ),
            ),
            onSubmitted: (_) => _searchUser(),
          ),

          // Found user card
          if (_foundUser != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.green.withValues(alpha: 0.1),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      _foundUser!.photoURL != null ? NetworkImage(_foundUser!.photoURL!) : null,
                  child: _foundUser!.photoURL == null
                      ? Text(_foundUser!.fullName[0].toUpperCase())
                      : null,
                ),
                title: Text(_foundUser!.fullName),
                subtitle: Text(_foundUser!.email ?? ''),
                trailing: FilledButton(
                  onPressed: _addExistingUser,
                  child: const Text('Ajouter'),
                ),
              ),
            ),
          ],

          // User not found - show invite form
          if (_userNotFound) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.orange.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.userPlus, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Utilisateur non inscrit',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Envoyez-lui une invitation pour rejoindre votre équipe.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom (optionnel)',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _sendInvitation,
                        icon: const FaIcon(FontAwesomeIcons.paperPlane, size: 16),
                        label: const Text('Envoyer l\'invitation'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _searchUser() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez un email valide')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _foundUser = null;
      _userNotFound = false;
    });

    final user = await widget.teamService.findUserByEmail(email);

    setState(() {
      _isLoading = false;
      if (user != null) {
        _foundUser = user;
      } else {
        _userNotFound = true;
      }
    });
  }

  Future<void> _addExistingUser() async {
    if (_foundUser == null) return;

    setState(() => _isLoading = true);

    final result = await widget.teamService.addToTeam(
      userId: _foundUser!.uid,
      studioId: widget.studioId,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  Future<void> _sendInvitation() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    final result = await widget.teamService.createInvitation(
      studioId: widget.studioId,
      studioName: widget.studioName,
      email: email,
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      if (result.data != null) {
        _showInvitationCode(result.data!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
      }
    }
  }

  void _showInvitationCode(TeamInvitation invitation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invitation créée'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Partagez ce code avec l\'ingénieur :'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    invitation.code,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.copy, size: 16),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: invitation.code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copié')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
