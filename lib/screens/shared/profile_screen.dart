import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/config/useme_theme.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/services/profile_photo_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/main.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

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
  final _photoService = ProfilePhotoService();
  bool _isLoading = false;
  bool _isUploadingPhoto = false;
  File? _selectedPhoto;

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
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticatedState) {
          return const AppLoader.fullScreen();
        }

        final user = authState.user as AppUser;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.myProfile),
            actions: [
              TextButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
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
                _buildSectionTitle(context, l10n.personalInfo),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
                ),
                if (user.isArtist) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stageNameController,
                    decoration: InputDecoration(
                      labelText: l10n.stageName,
                      prefixIcon: const Icon(Icons.star_outline),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: false, // Email cannot be changed
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phone,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 24),

                _buildSectionTitle(context, l10n.bio),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: l10n.tellAboutYourself,
                  ),
                ),
                const SizedBox(height: 32),

                // Account actions
                _buildSectionTitle(context, l10n.accountSection),
                const SizedBox(height: 12),
                _buildActionTile(
                  context,
                  icon: FontAwesomeIcons.key,
                  title: l10n.changePassword,
                  onTap: _changePassword,
                ),
                _buildActionTile(
                  context,
                  icon: FontAwesomeIcons.arrowRightFromBracket,
                  title: l10n.signOut,
                  onTap: _signOut,
                ),
                _buildActionTile(
                  context,
                  icon: FontAwesomeIcons.trash,
                  title: l10n.deleteMyAccount,
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

    // Determine what image to show
    ImageProvider? imageProvider;
    if (_selectedPhoto != null) {
      imageProvider = FileImage(_selectedPhoto!);
    } else if (user.photoURL != null) {
      imageProvider = NetworkImage(user.photoURL!);
    }

    return Center(
      child: GestureDetector(
        onTap: _isUploadingPhoto ? null : _changePhoto,
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
                image: imageProvider != null
                    ? DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _isUploadingPhoto
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : imageProvider == null
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

  Future<void> _changePhoto() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    final imageFile = await _photoService.pickImage(context);
    if (imageFile == null) return;

    setState(() {
      _selectedPhoto = imageFile;
      _isUploadingPhoto = true;
    });

    final user = authState.user as AppUser;
    final uploadResult = await _photoService.uploadProfilePhoto(
      userId: user.uid,
      imageFile: imageFile,
    );

    if (!mounted) return;

    if (uploadResult.code == 200 && (uploadResult.data?.isNotEmpty ?? false)) {
      // Update user with new photo URL
      final updatedUser = user.copyWith(photoURL: uploadResult.data);
      final updateResult = await useMeAuthService.updateUserProfile(updatedUser);

      setState(() => _isUploadingPhoto = false);

      if (updateResult.code == 200) {
        AppSnackBar.success(context, AppLocalizations.of(context)!.photoUpdated);
      } else {
        setState(() => _selectedPhoto = null);
        AppSnackBar.error(context, updateResult.message);
      }
    } else {
      setState(() {
        _selectedPhoto = null;
        _isUploadingPhoto = false;
      });
      AppSnackBar.error(context, uploadResult.message);
    }
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
        if (response.code == 200) {
          AppSnackBar.success(context, response.message);
          context.pop();
        } else {
          AppSnackBar.error(context, response.message);
        }
      }
    }
  }

  void _changePassword() async {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      context.read<AuthBloc>().add(ResetPasswordEvent(email: authState.user.email));
      AppSnackBar.success(context, l10n.resetEmailSent);
    }
  }

  void _signOut() {
    context.read<AuthBloc>().add(const SignOutEvent());
    context.go(AppRoutes.login);
  }

  void _showDeleteAccountDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const DeleteAccountEvent());
              context.go(AppRoutes.login);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
