import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/user_contact.dart';

/// Card displaying a contact in the network list.
class ContactCard extends StatelessWidget {
  final UserContact contact;
  final VoidCallback onTap;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: _buildAvatar(theme),
        title: Row(
          children: [
            Flexible(
              child: Text(
                contact.contactName,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (contact.isOnPlatform) ...[
              const SizedBox(width: 6),
              FaIcon(
                FontAwesomeIcons.solidCircleCheck,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
        subtitle: Text(
          contact.category.label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        trailing: contact.tags.isNotEmpty
            ? _buildTagChip(theme, contact.tags.first)
            : null,
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    if (contact.contactPhotoUrl != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(contact.contactPhotoUrl!),
      );
    }
    return CircleAvatar(
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        contact.contactName.isNotEmpty
            ? contact.contactName[0].toUpperCase()
            : '?',
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTagChip(ThemeData theme, String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
