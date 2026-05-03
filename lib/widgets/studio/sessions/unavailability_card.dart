import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uzme/core/models/models_exports.dart';
import 'package:uzme/l10n/app_localizations.dart';

/// Card to display an unavailability in the sessions list
class UnavailabilityCard extends StatelessWidget {
  final Unavailability unavailability;
  final String locale;

  const UnavailabilityCard({
    super.key,
    required this.unavailability,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm', locale);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildIcon(theme),
            const SizedBox(width: 12),
            Expanded(child: _buildContent(context, theme, timeFormat)),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.ban,
          size: 16,
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    DateFormat timeFormat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          unavailability.title ??
              AppLocalizations.of(context)!.unavailable,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            FaIcon(
              FontAwesomeIcons.clock,
              size: 10,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(width: 4),
            Text(
              '${timeFormat.format(unavailability.start)} - '
              '${timeFormat.format(unavailability.end)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                unavailability.source.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
