import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/common/dashboard/dashboard_exports.dart';

/// Recent artists section for studio dashboard
class StudioRecentArtists extends StatelessWidget {
  final AppLocalizations l10n;

  const StudioRecentArtists({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArtistBloc, ArtistState>(
      builder: (context, state) {
        if (state.artists.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DashboardSectionTitle(title: l10n.recentArtists),
                DashboardViewAllChip(
                  label: l10n.viewAll,
                  onTap: () => context.push(AppRoutes.artists),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.artists.take(8).length,
                itemBuilder: (context, index) {
                  final artist = state.artists[index];
                  return _ArtistChip(artist: artist);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ArtistChip extends StatelessWidget {
  final Artist artist;

  const _ArtistChip({required this.artist});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => context.push('/artists/${artist.id}'),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage:
                  artist.photoUrl != null ? NetworkImage(artist.photoUrl!) : null,
              child: artist.photoUrl == null
                  ? Text(
                      artist.displayName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 60,
              child: Text(
                artist.displayName.split(' ').first,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
