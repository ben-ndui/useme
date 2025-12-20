import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/config/useme_theme.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/main.dart';
import 'package:useme/routing/app_routes.dart';

/// Profile screen - Edit user profile
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _stageNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      final user = authState.user as AppUser;
      _nameController.text = user.displayName ?? user.name ?? '';
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
      _bioController.text = user.bio ?? '';
      _stageNameController.text = user.stageName ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _stageNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticatedState) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authState.user as AppUser;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mon profil'),
            actions: [
              TextButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enregistrer'),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Avatar section
                _buildAvatarSection(user),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    user.role.useMeLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Form fields
                _buildSectionTitle(context, 'Informations personnelles'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                ),
                if (user.isArtist) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stageNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de scène',
                      prefixIcon: Icon(Icons.star_outline),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: false, // Email cannot be changed
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 24),

                _buildSectionTitle(context, 'Bio'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Parlez de vous...',
                  ),
                ),
                const SizedBox(height: 32),

                // Account actions
                _buildSectionTitle(context, 'Compte'),
                const SizedBox(height: 12),
                _buildActionTile(
                  context,
                  icon: FontAwesomeIcons.key,
                  title: 'Changer le mot de passe',
                  onTap: _changePassword,
                ),
                _buildActionTile(
                  context,
                  icon: FontAwesomeIcons.arrowRightFromBracket,
                  title: 'Se déconnecter',
                  onTap: _signOut,
                ),
                _buildActionTile(
                  context,
                  icon: FontAwesomeIcons.trash,
                  title: 'Supprimer mon compte',
                  isDestructive: true,
                  onTap: _showDeleteAccountDialog,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarSection(AppUser user) {
    final theme = Theme.of(context);
    final initials = _getInitials(user);

    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [UseMeTheme.primaryColor, UseMeTheme.secondaryColor],
              ),
              shape: BoxShape.circle,
              image: user.photoURL != null
                  ? DecorationImage(
                      image: NetworkImage(user.photoURL!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user.photoURL == null
                ? Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.surface, width: 3),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.camera, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(AppUser user) {
    final name = user.displayName ?? user.name ?? user.email;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? Colors.red : theme.colorScheme.onSurface;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: FaIcon(icon, size: 18, color: isDestructive ? Colors.red : theme.colorScheme.primary),
      title: Text(title, style: TextStyle(color: color)),
      trailing: FaIcon(FontAwesomeIcons.chevronRight, size: 14, color: theme.colorScheme.outline),
      onTap: onTap,
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      final user = authState.user as AppUser;
      final updatedUser = user.copyWith(
        displayName: _nameController.text.trim(),
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        bio: _bioController.text.trim(),
        stageName: _stageNameController.text.trim(),
      );

      final response = await useMeAuthService.updateUserProfile(updatedUser);

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.code == 200 ? Colors.green : Colors.red,
          ),
        );

        if (response.code == 200) {
          context.pop();
        }
      }
    }
  }

  void _changePassword() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      context.read<AuthBloc>().add(ResetPasswordEvent(email: authState.user.email));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email de réinitialisation envoyé')),
      );
    }
  }

  void _signOut() {
    context.read<AuthBloc>().add(const SignOutEvent());
    context.go(AppRoutes.login);
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront supprimées définitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const DeleteAccountEvent());
              context.go(AppRoutes.login);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
