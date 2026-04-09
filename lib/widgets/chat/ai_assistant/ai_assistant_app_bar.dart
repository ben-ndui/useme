import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/config/useme_theme.dart';
import 'package:useme/l10n/app_localizations.dart';

/// App bar for the AI assistant screen — UZME branded, minimal.
class AIAssistantAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onClear;

  const AIAssistantAppBar({super.key, this.onClear});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          // Avatar IA — dégradé bleu UZME
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [UseMeTheme.accentColor, UseMeTheme.primaryColor],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: UseMeTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.solidStar, color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.aiAssistantTitle,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    l10n.alwaysAvailable,
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (onClear != null)
          IconButton(
            icon: FaIcon(FontAwesomeIcons.rotateRight, size: 16, color: cs.onSurface.withValues(alpha: 0.5)),
            tooltip: 'Nouvelle conversation',
            onPressed: onClear,
          ),
        const SizedBox(width: 4),
      ],
    );
  }
}
