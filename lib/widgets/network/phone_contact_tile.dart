import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Data class for a phone contact with platform match info.
class PhoneContactItem {
  final Contact contact;
  final String? email;
  final String? phone;
  final AppUser? platformUser;
  final bool isOnPlatform;

  const PhoneContactItem({
    required this.contact,
    this.email,
    this.phone,
    this.platformUser,
    required this.isOnPlatform,
  });
}

/// Tile displaying a phone contact with selection checkbox.
class PhoneContactTile extends StatelessWidget {
  final PhoneContactItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const PhoneContactTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundImage: item.contact.photo != null
                ? MemoryImage(item.contact.photo!)
                : null,
            child: item.contact.photo == null
                ? Text(
                    item.contact.displayName.isNotEmpty
                        ? item.contact.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          if (item.isOnPlatform)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.check,
                      size: 8, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        item.contact.displayName,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        item.isOnPlatform
            ? l10n.contactAlreadyOnUzme
            : (item.email ?? item.phone ?? ''),
        style: theme.textTheme.bodySmall?.copyWith(
          color: item.isOnPlatform
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
        ),
      ),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (_) => onTap(),
        shape: const CircleBorder(),
      ),
      onTap: onTap,
    );
  }
}
