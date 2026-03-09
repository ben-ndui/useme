import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Tile widget for a single studio item in the AI studios card
class AIStudioItemTile extends StatelessWidget {
  final Map<String, dynamic> studio;
  final bool isFavorites;

  const AIStudioItemTile({
    super.key,
    required this.studio,
    this.isFavorites = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPartner = studio['isPartner'] == true;

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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.building,
                size: 16,
                color: Colors.purple.shade400,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        studio['name'] ?? 'Studio',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isPartner) ...[
                      const SizedBox(width: 6),
                      _buildPartnerBadge(theme),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                _buildLocationRow(theme),
              ],
            ),
          ),
          if (isFavorites)
            FaIcon(
              FontAwesomeIcons.solidHeart,
              size: 14,
              color: Colors.red.shade400,
            ),
        ],
      ),
    );
  }

  Widget _buildPartnerBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(FontAwesomeIcons.solidStar, size: 8, color: Colors.amber.shade700),
          const SizedBox(width: 3),
          Text(
            'Partenaire',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 9,
              color: Colors.amber.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(ThemeData theme) {
    return Row(
      children: [
        FaIcon(
          FontAwesomeIcons.locationDot,
          size: 10,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            studio['city'] ?? studio['address'] ?? '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
