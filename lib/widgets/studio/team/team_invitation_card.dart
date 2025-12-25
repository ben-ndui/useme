import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/services/team_service.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Card displaying a pending team invitation
class TeamInvitationCard extends StatelessWidget {
  final TeamInvitation invitation;
  final VoidCallback onCancel;

  const TeamInvitationCard({
    super.key,
    required this.invitation,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.clock, size: 16, color: Colors.orange),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invitation.name ?? invitation.email,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    invitation.email,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          invitation.code,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.copy, size: 12),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: invitation.code));
                          AppSnackBar.success(context, 'Code copié');
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: FaIcon(FontAwesomeIcons.xmark, size: 16, color: theme.colorScheme.error),
              onPressed: onCancel,
            ),
          ],
        ),
      ),
    );
  }
}
