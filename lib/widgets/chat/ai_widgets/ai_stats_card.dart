import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Widget pour afficher les statistiques
class AIStatsCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const AIStatsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purple.withValues(alpha:0.2)),
      ),
      child: Column(
        children: [
          _buildHeader(context, theme),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildStatItem(theme, 'Sessions', data['totalSessions'] ?? data['sessionsCount'] ?? 0, FontAwesomeIcons.calendar, Colors.blue),
                _buildStatItem(theme, 'Revenus', '${data['totalRevenue'] ?? data['revenue'] ?? 0}\u20ac', FontAwesomeIcons.euroSign, Colors.green),
                _buildStatItem(theme, 'En attente', data['pendingCount'] ?? data['pending'] ?? 0, FontAwesomeIcons.clock, Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, dynamic value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: FaIcon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha:0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.chartLine, size: 14, color: Colors.purple),
          const SizedBox(width: 8),
          Text(l10n.statistics, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
