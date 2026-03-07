import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../config/useme_theme.dart';
import '../../l10n/app_localizations.dart';

/// Types de permissions supportées par le dialog
enum AppPermissionType {
  camera,
  microphone,
  location,
  photos,
  notification,
  contacts,
}

/// Dialog custom affiché AVANT le popup système pour expliquer la permission.
///
/// Usage:
/// ```dart
/// final granted = await PermissionDialog.requestPermission(
///   context,
///   type: AppPermissionType.camera,
/// );
/// if (granted) { /* utiliser la caméra */ }
/// ```
class PermissionDialog extends StatelessWidget {
  final AppPermissionType type;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final bool isDeniedForever;

  const PermissionDialog({
    super.key,
    required this.type,
    required this.onAccept,
    required this.onDecline,
    this.isDeniedForever = false,
  });

  /// Demande une permission avec le dialog custom puis le popup système.
  /// Retourne `true` si la permission est accordée.
  static Future<bool> requestPermission(
    BuildContext context, {
    required AppPermissionType type,
  }) async {
    final permission = _toPermission(type);

    // Déjà accordée → pas besoin de dialog
    final currentStatus = await permission.status;
    if (currentStatus.isGranted) return true;

    // Refusée définitivement → proposer les réglages
    if (currentStatus.isPermanentlyDenied) {
      if (!context.mounted) return false;
      return await _showDeniedForeverDialog(context, type);
    }

    // Afficher notre dialog custom
    if (!context.mounted) return false;
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PermissionDialog(
        type: type,
        onAccept: () => Navigator.of(ctx).pop(true),
        onDecline: () => Navigator.of(ctx).pop(false),
      ),
    );

    if (accepted != true) return false;

    // Demander la permission système
    final status = await permission.request();

    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;
      return await _showDeniedForeverDialog(context, type);
    }

    return status.isGranted;
  }

  static Future<bool> _showDeniedForeverDialog(
    BuildContext context,
    AppPermissionType type,
  ) async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => PermissionDialog(
        type: type,
        isDeniedForever: true,
        onAccept: () {
          Navigator.of(ctx).pop(true);
          openAppSettings();
        },
        onDecline: () => Navigator.of(ctx).pop(false),
      ),
    );
    return accepted ?? false;
  }

  static Permission _toPermission(AppPermissionType type) {
    switch (type) {
      case AppPermissionType.camera:
        return Permission.camera;
      case AppPermissionType.microphone:
        return Permission.microphone;
      case AppPermissionType.location:
        return Permission.location;
      case AppPermissionType.photos:
        return Permission.photos;
      case AppPermissionType.notification:
        return Permission.notification;
      case AppPermissionType.contacts:
        return Permission.contacts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final config = _getConfig(l10n);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.all(28),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône dans un cercle coloré
          _PermissionIcon(
            icon: config.icon,
            color: config.color,
            isDenied: isDeniedForever,
          ),
          const SizedBox(height: 24),

          // Titre
          Text(
            isDeniedForever ? l10n.permissionDeniedTitle : config.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            isDeniedForever ? l10n.permissionDeniedDesc : config.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // Boutons
          _buildButtons(context, l10n, config),
        ],
      ),
    );
  }

  Widget _buildButtons(
    BuildContext context,
    AppLocalizations l10n,
    _PermissionConfig config,
  ) {
    return Row(
      children: [
        // Bouton secondaire
        Expanded(
          child: OutlinedButton(
            onPressed: onDecline,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(l10n.permissionNotNow),
          ),
        ),
        const SizedBox(width: 12),
        // Bouton principal
        Expanded(
          child: FilledButton.icon(
            onPressed: onAccept,
            style: FilledButton.styleFrom(
              backgroundColor: config.color,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: isDeniedForever
                ? const FaIcon(FontAwesomeIcons.gear, size: 14)
                : const SizedBox.shrink(),
            label: Text(
              isDeniedForever
                  ? l10n.permissionOpenSettings
                  : l10n.permissionContinue,
            ),
          ),
        ),
      ],
    );
  }

  _PermissionConfig _getConfig(AppLocalizations l10n) {
    switch (type) {
      case AppPermissionType.camera:
        return _PermissionConfig(
          icon: FontAwesomeIcons.camera,
          color: UseMeTheme.primaryColor,
          title: l10n.permissionCameraTitle,
          description: l10n.permissionCameraDesc,
        );
      case AppPermissionType.microphone:
        return _PermissionConfig(
          icon: FontAwesomeIcons.microphone,
          color: UseMeTheme.errorColor,
          title: l10n.permissionMicrophoneTitle,
          description: l10n.permissionMicrophoneDesc,
        );
      case AppPermissionType.location:
        return _PermissionConfig(
          icon: FontAwesomeIcons.locationDot,
          color: UseMeTheme.successColor,
          title: l10n.permissionLocationTitle,
          description: l10n.permissionLocationDesc,
        );
      case AppPermissionType.photos:
        return _PermissionConfig(
          icon: FontAwesomeIcons.images,
          color: UseMeTheme.accentColor,
          title: l10n.permissionPhotosTitle,
          description: l10n.permissionPhotosDesc,
        );
      case AppPermissionType.notification:
        return _PermissionConfig(
          icon: FontAwesomeIcons.bell,
          color: UseMeTheme.warningColor,
          title: l10n.permissionNotificationTitle,
          description: l10n.permissionNotificationDesc,
        );
      case AppPermissionType.contacts:
        return _PermissionConfig(
          icon: FontAwesomeIcons.addressBook,
          color: UseMeTheme.infoColor,
          title: l10n.permissionContactsTitle,
          description: l10n.permissionContactsDesc,
        );
    }
  }
}

/// Icône animée dans un cercle coloré
class _PermissionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isDenied;

  const _PermissionIcon({
    required this.icon,
    required this.color,
    this.isDenied = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (isDenied ? UseMeTheme.errorColor : color)
            .withValues(alpha: 0.12),
      ),
      child: Center(
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isDenied ? UseMeTheme.errorColor : color)
                .withValues(alpha: 0.18),
          ),
          child: Center(
            child: FaIcon(
              isDenied ? FontAwesomeIcons.ban : icon,
              size: 28,
              color: isDenied ? UseMeTheme.errorColor : color,
            ),
          ),
        ),
      ),
    );
  }
}

/// Configuration interne pour chaque type de permission
class _PermissionConfig {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _PermissionConfig({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}
