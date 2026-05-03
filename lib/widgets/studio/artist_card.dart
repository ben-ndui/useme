import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:uzme/core/models/models_exports.dart';
import 'package:uzme/widgets/favorite/favorite_button.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;

  const ArtistCard({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/artists/${artist.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: artist.photoUrl != null
                    ? NetworkImage(artist.photoUrl!)
                    : null,
                child: artist.photoUrl == null
                    ? Text(
                        artist.displayName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (artist.stageName != null &&
                        artist.stageName != artist.name)
                      Text(
                        artist.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    if (artist.hasGenres)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          artist.genresDisplay,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              FavoriteButtonCompact(
                targetId: artist.id,
                type: FavoriteType.artist,
                targetName: artist.displayName,
                targetPhotoUrl: artist.photoUrl,
                size: 18,
              ),
              const SizedBox(width: 8),
              FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 16,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
