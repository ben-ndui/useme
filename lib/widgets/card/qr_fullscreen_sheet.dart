import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/widgets/card/holo_card_theme.dart';

/// Fullscreen bottom sheet displaying a large QR code for scanning.
class QrFullscreenSheet extends StatelessWidget {
  final AppUser user;

  const QrFullscreenSheet({super.key, required this.user});

  static Future<void> show(BuildContext context, AppUser user) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QrFullscreenSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = HoloCardTheme.forRole(user.role, isPioneer: user.isPioneer);
    final cs = Theme.of(context).colorScheme;
    final isStudio = user.isStudio || user.isSuperAdmin;
    final displayName = isStudio
        ? user.studioDisplayName
        : (user.stageName ?? user.displayName ?? user.name ?? '');
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Container(
      height: screenHeight * 0.7,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: cs.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            displayName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            theme.roleLabel,
            style: TextStyle(
              fontSize: 14,
              color: theme.accentColor,
              fontWeight: FontWeight.w500,
            ),
          ),

          const Spacer(),

          // QR Code
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.glowColor.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: QrImageView(
              data: 'https://uzme.app/u/${user.uid}',
              version: QrVersions.auto,
              size: 220,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: theme.primaryColor,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: theme.primaryColor,
              ),
            ),
          ),

          const Spacer(),

          // Hint
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.qrcode,
                    size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'Scanne ce code pour voir mon profil',
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 16),
        ],
      ),
    );
  }
}
