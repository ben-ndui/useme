import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A standard settings tile with icon, title, subtitle and navigation
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive ? Colors.red : theme.colorScheme.onSurface;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: FaIcon(
            icon,
            size: 18,
            color: isDestructive ? Colors.red : theme.colorScheme.primary,
          ),
        ),
      ),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle, style: theme.textTheme.bodySmall)
          : null,
      trailing: isDestructive
          ? null
          : FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 14,
              color: theme.colorScheme.outline,
            ),
      onTap: onTap,
    );
  }
}
