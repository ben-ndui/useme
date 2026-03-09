import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

/// Widget pour afficher une liste de sessions
class AISessionsCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const AISessionsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessions = (data['sessions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final count = data['count'] ?? sessions.length;

    if (sessions.isEmpty) {
      return _buildEmptyCard(theme, 'Aucune session trouvée', FontAwesomeIcons.calendar);
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purple.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, 'Sessions', FontAwesomeIcons.calendar, count),
          ...sessions.take(5).map((s) => _buildSessionItem(theme, s)),
          if (sessions.length > 5) _buildMoreIndicator(theme, sessions.length - 5),
        ],
      ),
    );
  }

  Widget _buildSessionItem(ThemeData theme, Map<String, dynamic> session) {
    final date = _parseDate(session['date']);
    final status = session['status'] ?? 'unknown';
    final statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha:0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session['artistName'] ?? session['serviceName'] ?? 'Session',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${session['serviceName'] ?? ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date != null ? DateFormat('dd/MM').format(date) : '-',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${session['startTime'] ?? ''} - ${session['endTime'] ?? ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    return switch (status) {
      'confirmed' => Colors.green,
      'pending' => Colors.orange,
      'inProgress' => Colors.blue,
      'completed' => Colors.grey,
      'cancelled' || 'declined' => Colors.red,
      _ => Colors.grey,
    };
  }

  DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  Widget _buildHeader(ThemeData theme, String title, IconData icon, int count) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha:0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          FaIcon(icon, size: 14, color: Colors.purple),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(ThemeData theme, String message, IconData icon) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            FaIcon(icon, size: 16, color: theme.colorScheme.outline),
            const SizedBox(width: 12),
            Text(message, style: TextStyle(color: theme.colorScheme.outline)),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreIndicator(ThemeData theme, int remaining) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        '+ $remaining autres...',
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.purple,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
