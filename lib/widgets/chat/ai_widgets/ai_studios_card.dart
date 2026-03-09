import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'ai_studio_item_tile.dart';

/// Widget pour afficher une liste de studios
class AIStudiosCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isFavorites;

  const AIStudiosCard({
    super.key,
    required this.data,
    this.isFavorites = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studios = (data['studios'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    if (studios.isEmpty) {
      return _buildEmptyCard(
        theme,
        isFavorites ? 'Aucun studio favori' : 'Aucun studio trouvé',
      );
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
          _buildHeader(theme, studios.length),
          ...studios.take(5).map(
            (s) => AIStudioItemTile(studio: s, isFavorites: isFavorites),
          ),
          if (studios.length > 5) _buildMoreIndicator(theme, studios.length - 5),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, int count) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha:0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          FaIcon(
            isFavorites ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.building,
            size: 14,
            color: isFavorites ? Colors.red.shade400 : Colors.purple,
          ),
          const SizedBox(width: 8),
          Text(
            isFavorites ? 'Studios favoris' : 'Studios',
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

  Widget _buildEmptyCard(ThemeData theme, String message) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            FaIcon(
              isFavorites ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.building,
              size: 16,
              color: theme.colorScheme.outline,
            ),
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
