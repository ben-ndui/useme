import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Bottom sheet for attachment options
class AttachmentOptionsSheet extends StatelessWidget {
  final VoidCallback onFilePickerTap;
  final VoidCallback onBusinessObjectTap;

  const AttachmentOptionsSheet({
    super.key,
    required this.onFilePickerTap,
    required this.onBusinessObjectTap,
  });

  static void show({
    required BuildContext context,
    required VoidCallback onFilePickerTap,
    required VoidCallback onBusinessObjectTap,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => AttachmentOptionsSheet(
        onFilePickerTap: () {
          Navigator.pop(ctx);
          onFilePickerTap();
        },
        onBusinessObjectTap: () {
          Navigator.pop(ctx);
          onBusinessObjectTap();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDragHandle(theme),
            const SizedBox(height: 16),
            ListTile(
              leading: _buildOptionIcon(FontAwesomeIcons.file, theme.colorScheme.primary),
              title: const Text('Fichier ou photo'),
              onTap: onFilePickerTap,
            ),
            ListTile(
              leading: _buildOptionIcon(FontAwesomeIcons.music, theme.colorScheme.tertiary),
              title: const Text('Session ou réservation'),
              onTap: onBusinessObjectTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle(ThemeData theme) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildOptionIcon(IconData icon, Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: FaIcon(icon, size: 18, color: color)),
    );
  }
}
