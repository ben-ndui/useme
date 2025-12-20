import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';

/// Bottom sheet for selecting user role (used after social login)
class RoleSelectorSheet extends StatelessWidget {
  final bool isNewUser;

  const RoleSelectorSheet({super.key, this.isNewUser = false});

  static void show(BuildContext context, {bool isNewUser = false}) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: RoleSelectorSheet(isNewUser: isNewUser),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              'Choisissez votre profil',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isNewUser ? 'Cette action est definitive' : 'Comment souhaitez-vous utiliser l\'app ?',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.buildingUser, size: 18, color: Colors.purple),
                ),
              ),
              title: const Text('Studio'),
              subtitle: const Text('Je possede un studio'),
              trailing: const FaIcon(FontAwesomeIcons.chevronRight, size: 14),
              onTap: () => _selectRole(context, BaseUserRole.admin),
            ),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.headphones, size: 18, color: Colors.orange),
                ),
              ),
              title: const Text('Ingenieur son'),
              subtitle: const Text('Je travaille dans un studio'),
              trailing: const FaIcon(FontAwesomeIcons.chevronRight, size: 14),
              onTap: () => _selectRole(context, BaseUserRole.worker),
            ),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.music, size: 18, color: Colors.blue),
                ),
              ),
              title: const Text('Artiste'),
              subtitle: const Text('Je veux reserver des sessions'),
              trailing: const FaIcon(FontAwesomeIcons.chevronRight, size: 14),
              onTap: () => _selectRole(context, BaseUserRole.client),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _selectRole(BuildContext context, BaseUserRole role) {
    Navigator.pop(context);
    context.read<AuthBloc>().add(CompleteSocialSignUpEvent(role: role));
  }
}
