import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:uzme/config/responsive_config.dart';
import 'package:uzme/core/blocs/blocs_exports.dart';
import 'package:uzme/core/models/app_user.dart';
import 'package:uzme/core/models/favorite.dart';
import 'package:uzme/core/services/pro_profile_service.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/widgets/common/app_loader.dart';
import 'package:uzme/widgets/favorite/favorite_button.dart';
import 'package:uzme/widgets/pro/pro_detail_bottom_sheet.dart';

/// Écran listant les favoris de l'utilisateur (adapté selon le rôle).
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthBloc>().state;

    // Déterminer les tabs selon le rôle
    final isStudio = authState is AuthAuthenticatedState &&
        authState.user.role.name == 'admin';

    final tabs = isStudio
        ? [
            _TabConfig(
              label: l10n.artistsLabel,
              type: FavoriteType.artist,
              emptyIcon: FontAwesomeIcons.microphoneLines,
              emptyTitle: l10n.noFavoriteArtists,
              emptySubtitle: l10n.addArtistsToFavorite,
            ),
          ]
        : [
            _TabConfig(
              label: l10n.studiosLabel,
              type: FavoriteType.studio,
              emptyIcon: FontAwesomeIcons.recordVinyl,
              emptyTitle: l10n.noFavoriteStudios,
              emptySubtitle: l10n.exploreStudiosToFavorite,
            ),
            _TabConfig(
              label: l10n.engineersLabel,
              type: FavoriteType.engineer,
              emptyIcon: FontAwesomeIcons.headphones,
              emptyTitle: l10n.noFavoriteEngineers,
              emptySubtitle: l10n.discoverEngineersToFavorite,
            ),
            _TabConfig(
              label: l10n.prosLabel,
              type: FavoriteType.pro,
              emptyIcon: FontAwesomeIcons.briefcase,
              emptyTitle: l10n.noFavoritePros,
              emptySubtitle: l10n.discoverProsToFavorite,
            ),
          ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.myFavorites),
          bottom: tabs.length > 1
              ? TabBar(
                  tabs: tabs.map((t) => Tab(text: t.label)).toList(),
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  indicatorColor: theme.colorScheme.primary,
                )
              : null,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
            child: BlocBuilder<FavoriteBloc, FavoriteState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const AppLoader();
            }

            if (tabs.length == 1) {
              // Single tab - no TabBarView needed
              final tab = tabs.first;
              return _FavoritesList(
                favorites: state.getFavoritesByType(tab.type),
                emptyIcon: tab.emptyIcon,
                emptyTitle: tab.emptyTitle,
                emptySubtitle: tab.emptySubtitle,
              );
            }

            return TabBarView(
              children: tabs.map((tab) => _FavoritesList(
                favorites: state.getFavoritesByType(tab.type),
                emptyIcon: tab.emptyIcon,
                emptyTitle: tab.emptyTitle,
                emptySubtitle: tab.emptySubtitle,
              )).toList(),
            );
          },
        ),
          ),
        ),
      ),
    );
  }
}

class _TabConfig {
  final String label;
  final FavoriteType type;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;

  const _TabConfig({
    required this.label,
    required this.type,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
  });
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

    return BlocListener<MessagingBloc, MessagingState>(
      listenWhen: (_, current) => current is ChatOpenState,
      listener: (context, state) {
        if (state is ChatOpenState) {
          context.push('/conversations/${state.conversation.id}');
        }
      },
      child: Card(
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
                      favorite.targetName ?? AppLocalizations.of(context)!.unnamed,
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
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    if (favorite.targetPhotoUrl != null && favorite.targetPhotoUrl!.isNotEmpty) {
      final initial = (favorite.targetName?.isNotEmpty == true)
          ? favorite.targetName![0].toUpperCase()
          : '?';

      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(favorite.targetPhotoUrl!),
        onBackgroundImageError: (_, __) {},
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
    switch (favorite.type) {
      case FavoriteType.studio:
        context.push(
          '/artist/request?studioId=${favorite.targetId}'
          '&studioName=${Uri.encodeComponent(favorite.targetName ?? '')}',
        );
        break;
      case FavoriteType.engineer:
      case FavoriteType.artist:
        _navigateToUserProfile(context);
        break;
      case FavoriteType.pro:
        _navigateToProProfile(context);
        break;
    }
  }

  Future<void> _navigateToUserProfile(BuildContext context) async {
    final user = await ProProfileService().getUser(favorite.targetId);
    if (user == null || !context.mounted) return;
    if (user.hasProProfile) {
      ProDetailBottomSheet.show(context, user);
    } else {
      _startConversation(context, user);
    }
  }

  Future<void> _navigateToProProfile(BuildContext context) async {
    final user = await ProProfileService().getProUser(favorite.targetId);
    if (user != null && context.mounted) {
      ProDetailBottomSheet.show(context, user);
    }
  }

  void _startConversation(BuildContext context, AppUser user) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;
    final l10n = AppLocalizations.of(context)!;
    final currentUser = authState.user as AppUser;
    final currentUserInfo = ParticipantInfo(
      name: currentUser.displayName ?? currentUser.name ?? l10n.user,
      avatarUrl: currentUser.photoURL,
      role: currentUser.role.useMeLabel,
    );
    final otherUserInfo = ParticipantInfo(
      name: user.displayName ?? user.name ?? l10n.user,
      avatarUrl: user.photoURL,
      role: user.role.useMeLabel,
    );
    context.read<MessagingBloc>().add(StartPrivateConversationEvent(
          otherUserId: user.uid,
          otherUserInfo: otherUserInfo,
          currentUserInfo: currentUserInfo,
        ));
  }
}
