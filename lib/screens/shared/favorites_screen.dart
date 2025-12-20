import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/favorite.dart';
import 'package:useme/widgets/favorite/favorite_button.dart';

/// Écran listant les favoris de l'utilisateur.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes favoris'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Studios'),
              Tab(text: 'Ingénieurs'),
            ],
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
          ),
        ),
        body: BlocBuilder<FavoriteBloc, FavoriteState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              children: [
                _FavoritesList(
                  favorites: state.getFavoritesByType(FavoriteType.studio),
                  emptyIcon: FontAwesomeIcons.recordVinyl,
                  emptyTitle: 'Aucun studio favori',
                  emptySubtitle: 'Explorez les studios et ajoutez-les à vos favoris',
                ),
                _FavoritesList(
                  favorites: state.getFavoritesByType(FavoriteType.engineer),
                  emptyIcon: FontAwesomeIcons.headphones,
                  emptyTitle: 'Aucun ingénieur favori',
                  emptySubtitle: 'Découvrez les ingénieurs et ajoutez-les à vos favoris',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  final List<Favorite> favorites;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;

  const _FavoritesList({
    required this.favorites,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _FavoriteCard(favorite: favorites[index]);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              emptyIcon,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              emptyTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Favorite favorite;

  const _FavoriteCard({required this.favorite});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(theme),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      favorite.targetName ?? 'Sans nom',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (favorite.targetAddress != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.locationDot,
                            size: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              favorite.targetAddress!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Bouton favori
              FavoriteButton(
                targetId: favorite.targetId,
                type: favorite.type,
                targetName: favorite.targetName,
                targetPhotoUrl: favorite.targetPhotoUrl,
                targetAddress: favorite.targetAddress,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    if (favorite.targetPhotoUrl != null && favorite.targetPhotoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(favorite.targetPhotoUrl!),
      );
    }

    final initial = (favorite.targetName?.isNotEmpty == true)
        ? favorite.targetName![0].toUpperCase()
        : '?';

    return CircleAvatar(
      radius: 28,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    // Navigation vers le détail selon le type
    switch (favorite.type) {
      case FavoriteType.studio:
        context.push('/artist/request?studioId=${favorite.targetId}&studioName=${Uri.encodeComponent(favorite.targetName ?? '')}');
        break;
      case FavoriteType.engineer:
        // TODO: Navigation vers profil ingénieur
        break;
      case FavoriteType.artist:
        // TODO: Navigation vers profil artiste
        break;
    }
  }
}
