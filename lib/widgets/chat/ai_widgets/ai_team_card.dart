import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uzme/l10n/app_localizations.dart';

/// Widget pour afficher l'equipe
class AITeamCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const AITeamCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final engineers = (data['engineers'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    if (engineers.isEmpty) {
      return _buildEmptyCard(context, theme);
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purple.withValues(alpha:0.2)),
      ),
      child: Column(
        children: [
          _buildHeader(context, theme, engineers.length),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: engineers.map((e) => _buildEngineerChip(theme, e)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngineerChip(ThemeData theme, Map<String, dynamic> engineer) {
    final isAvailable = engineer['isAvailable'] ?? true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green.withValues(alpha:0.1) : Colors.grey.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAvailable ? Colors.green.withValues(alpha:0.3) : Colors.grey.withValues(alpha:0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.purple.withValues(alpha:0.2),
            child: Text(
              (engineer['name'] ?? 'I')[0].toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            engineer['name'] ?? 'Ingénieur',
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          if (!isAvailable) ...[
            const SizedBox(width: 4),
            Icon(Icons.do_not_disturb, size: 12, color: Colors.grey.shade600),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, int count) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha:0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.userTie, size: 14, color: Colors.purple),
          const SizedBox(width: 8),
          Text(l10n.team, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count', style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.purple, fontWeight: FontWeight.bold,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            FaIcon(FontAwesomeIcons.userTie, size: 16, color: theme.colorScheme.outline),
            const SizedBox(width: 12),
            Text(l10n.noEngineerInTeam, style: TextStyle(color: theme.colorScheme.outline)),
          ],
        ),
      ),
    );
  }
}
