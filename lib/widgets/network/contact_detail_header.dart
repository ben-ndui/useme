import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/user_contact.dart';

/// Header widget for contact detail showing avatar, name, and category.
class ContactDetailHeader extends StatelessWidget {
  final UserContact contact;

  const ContactDetailHeader({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: contact.contactPhotoUrl != null
              ? NetworkImage(contact.contactPhotoUrl!)
              : null,
          child: contact.contactPhotoUrl == null
              ? Text(
                  contact.contactName.isNotEmpty
                      ? contact.contactName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      contact.contactName,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (contact.isOnPlatform) ...[
                    const SizedBox(width: 8),
                    FaIcon(FontAwesomeIcons.solidCircleCheck,
                        size: 16, color: theme.colorScheme.primary),
                  ],
                ],
              ),
              Text(
                contact.category.label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
