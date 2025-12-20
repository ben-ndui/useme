import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/config/useme_theme.dart';
import 'package:useme/core/models/discovered_studio.dart';

/// Simple bottom sheet showing basic studio info for non-authenticated users
class StudioPreviewBottomSheet extends StatelessWidget {
  final DiscoveredStudio studio;

  const StudioPreviewBottomSheet({super.key, required this.studio});

  static void show(BuildContext context, DiscoveredStudio studio) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StudioPreviewBottomSheet(studio: studio),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Studio photo
                _buildStudioAvatar(theme),
                const SizedBox(width: 16),
                // Studio info
                Expanded(child: _buildStudioInfo(theme)),
              ],
            ),
          ),
          // CTA
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _buildCTA(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildStudioAvatar(ThemeData theme) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [UseMeTheme.primaryColor, UseMeTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: studio.photoUrl != null
            ? DecorationImage(
                image: NetworkImage(studio.photoUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: studio.photoUrl == null
          ? Center(
              child: FaIcon(
                FontAwesomeIcons.buildingUser,
                color: Colors.white,
                size: 28,
              ),
            )
          : null,
    );
  }

  Widget _buildStudioInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                studio.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (studio.isPartner) _buildPartnerBadge(theme),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (studio.rating != null) ...[
              FaIcon(FontAwesomeIcons.solidStar, size: 12, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                studio.rating!.toStringAsFixed(1),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
            ],
            FaIcon(
              FontAwesomeIcons.locationDot,
              size: 12,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(width: 4),
            Text(
              studio.formattedDistance,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPartnerBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(FontAwesomeIcons.solidCircleCheck, size: 10, color: Colors.green),
          const SizedBox(width: 4),
          Text(
            'Partenaire',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UseMeTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: UseMeTheme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: UseMeTheme.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.rightToBracket,
                size: 16,
                color: UseMeTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connectez-vous pour reserver',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: UseMeTheme.primaryColor,
                  ),
                ),
                Text(
                  'Et decouvrez ce studio',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          FaIcon(
            FontAwesomeIcons.chevronDown,
            size: 14,
            color: UseMeTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}
