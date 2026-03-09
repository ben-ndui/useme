import 'package:flutter/material.dart';
import 'package:useme/l10n/app_localizations.dart';

/// App bar for the AI assistant conversation screen.
class AIAssistantAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const AIAssistantAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.blue.shade400],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.aiAssistantTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                l10n.alwaysAvailable,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
