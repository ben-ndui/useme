import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Widget pour afficher une liste de services
class AIServicesCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const AIServicesCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final services = (data['services'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    if (services.isEmpty) {
      return _buildEmptyCard(theme, 'Aucun service trouvé');
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
          _buildHeader(theme, 'Services', FontAwesomeIcons.tags, services.length),
          ...services.map((s) => _buildServiceItem(theme, s)),
        ],
      ),
    );
  }

  Widget _buildServiceItem(ThemeData theme, Map<String, dynamic> service) {
    final price = service['price'] ?? service['pricePerHour'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha:0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['name'] ?? 'Service',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (service['description'] != null)
                  Text(
                    service['description'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (price != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$price\u20ac/h',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
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
          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
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

  Widget _buildEmptyCard(ThemeData theme, String message) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            FaIcon(FontAwesomeIcons.tags, size: 16, color: theme.colorScheme.outline),
            const SizedBox(width: 12),
            Text(message, style: TextStyle(color: theme.colorScheme.outline)),
          ],
        ),
      ),
    );
  }
}
