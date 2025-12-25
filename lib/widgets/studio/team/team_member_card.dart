import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/app_user.dart';

/// Card displaying a team member
class TeamMemberCard extends StatelessWidget {
  final AppUser member;
  final VoidCallback onOptionsPressed;

  const TeamMemberCard({
    super.key,
    required this.member,
    required this.onOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: member.photoURL != null ? NetworkImage(member.photoURL!) : null,
          child: member.photoURL == null
              ? Text(
                  (member.displayName ?? member.email ?? 'U')[0].toUpperCase(),
                  style: TextStyle(color: theme.colorScheme.primary),
                )
              : null,
        ),
        title: Text(
          member.fullName,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(member.email ?? '', style: theme.textTheme.bodySmall),
        trailing: IconButton(
          icon: FaIcon(FontAwesomeIcons.ellipsisVertical, size: 16, color: theme.colorScheme.outline),
          onPressed: onOptionsPressed,
        ),
      ),
    );
  }
}
