import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

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
              l10n.chooseYourProfile,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isNewUser ? l10n.actionIsPermanent : l10n.howToUseApp,
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
              title: Text(l10n.studio),
              subtitle: Text(l10n.iOwnStudio),
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
              title: Text(l10n.soundEngineer),
              subtitle: Text(l10n.iWorkInStudio),
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
              title: Text(l10n.artist),
              subtitle: Text(l10n.iWantToBookSessions),
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
