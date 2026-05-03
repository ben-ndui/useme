import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uzme/core/services/notification_service.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/main.dart';
import 'package:uzme/widgets/common/permission_dialog.dart';
import 'package:uzme/widgets/common/snackbar/app_snackbar.dart';

/// A notification toggle tile for settings pages
class SettingsNotificationTile extends StatelessWidget {
  final String? userId;

  const SettingsNotificationTile({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: preferencesService,
      builder: (context, _) {
        final isEnabled = preferencesService.notificationsEnabled;

        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: FaIcon(
                isEnabled ? FontAwesomeIcons.solidBell : FontAwesomeIcons.bellSlash,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          title: Text(l10n.notifications),
          subtitle: Text(
            isEnabled ? l10n.notificationsEnabled : l10n.notificationsDisabled,
            style: theme.textTheme.bodySmall,
          ),
          trailing: Switch.adaptive(
            value: isEnabled,
            onChanged: (value) => _toggleNotifications(context, value, l10n),
          ),
        );
      },
    );
  }

  Future<void> _toggleNotifications(
    BuildContext context,
    bool enable,
    AppLocalizations l10n,
  ) async {
    if (enable) {
      final granted = await PermissionDialog.requestPermission(
        context,
        type: AppPermissionType.notification,
      );
      if (granted) {
        await UseMeNotificationService.instance.requestPermissions();
        await preferencesService.setNotificationsEnabled(true, userId: userId);
      } else {
        if (context.mounted) {
          AppSnackBar.warning(context, l10n.enableNotificationsInSettings);
        }
      }
    } else {
      await preferencesService.setNotificationsEnabled(false, userId: userId);
    }
  }
}
