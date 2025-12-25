import 'package:flutter/material.dart';

/// A "View all" link chip for dashboard sections
class DashboardViewAllChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const DashboardViewAllChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
