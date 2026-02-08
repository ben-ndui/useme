import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/services/team_service.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Bottom sheet for adding a team member
class AddTeamMemberSheet extends StatefulWidget {
  final String studioId;
  final String studioName;
  final TeamService teamService;

  const AddTeamMemberSheet({
    super.key,
    required this.studioId,
    required this.studioName,
    required this.teamService,
  });

  @override
  State<AddTeamMemberSheet> createState() => _AddTeamMemberSheetState();
}

class _AddTeamMemberSheetState extends State<AddTeamMemberSheet> {
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
          _buildDragHandle(theme),
          const SizedBox(height: 20),
          _buildHeader(theme),
          const SizedBox(height: 24),
          _buildEmailField(),
          if (_foundUser != null) _buildFoundUserCard(theme),
          if (_userNotFound) _buildInviteForm(theme),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDragHandle(ThemeData theme) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ajouter un membre',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Recherchez par email ou invitez un nouvel ingénieur',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        suffixIcon: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : IconButton(icon: const Icon(Icons.search), onPressed: _searchUser),
      ),
      onSubmitted: (_) => _searchUser(),
    );
  }

  Widget _buildFoundUserCard(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        color: Colors.green.withValues(alpha: 0.1),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: _foundUser!.photoURL != null ? NetworkImage(_foundUser!.photoURL!) : null,
            child: _foundUser!.photoURL == null ? Text(_foundUser!.fullName[0].toUpperCase()) : null,
          ),
          title: Text(_foundUser!.fullName),
          subtitle: Text(_foundUser!.email),
          trailing: FilledButton(onPressed: _addExistingUser, child: const Text('Ajouter')),
        ),
      ),
    );
  }

  Widget _buildInviteForm(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
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
              Text('Envoyez-lui une invitation pour rejoindre votre équipe.', style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom (optionnel)', prefixIcon: Icon(Icons.person_outline)),
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
    );
  }

  Future<void> _searchUser() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      AppSnackBar.warning(context, 'Entrez un email valide');
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

    final result = await widget.teamService.addToTeam(userId: _foundUser!.uid, studioId: widget.studioId);

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      AppSnackBar.success(context, result.message);
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
        AppSnackBar.error(context, result.message);
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
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 4),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.copy, size: 16),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: invitation.code));
                      AppSnackBar.success(context, 'Code copié');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }
}
