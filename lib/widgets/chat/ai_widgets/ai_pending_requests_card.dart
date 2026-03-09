import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Widget pour afficher les demandes en attente
class AIPendingRequestsCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const AIPendingRequestsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requests = (data['requests'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    if (requests.isEmpty) {
      return Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              FaIcon(FontAwesomeIcons.inbox, size: 16, color: theme.colorScheme.outline),
              const SizedBox(width: 12),
              Text('Aucune demande en attente', style: TextStyle(color: theme.colorScheme.outline)),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.withValues(alpha:0.3)),
      ),
      child: Column(
        children: [
          _buildHeader(context, theme, requests.length),
          ...requests.take(5).map((r) => _buildRequestItem(theme, r)),
        ],
      ),
    );
  }

  Widget _buildRequestItem(ThemeData theme, Map<String, dynamic> request) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha:0.3))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: const FaIcon(FontAwesomeIcons.userClock, size: 12, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request['artistName'] ?? 'Artiste',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  request['serviceName'] ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
          Text(
            request['date'] ?? '',
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, int count) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha:0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.inbox, size: 14, color: Colors.orange),
          const SizedBox(width: 8),
          Text(l10n.pendingRequests, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count', style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.orange.shade800, fontWeight: FontWeight.bold,
            )),
          ),
        ],
      ),
    );
  }
}
