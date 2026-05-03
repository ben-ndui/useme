import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:uzme/config/responsive_config.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:uzme/core/blocs/blocs_exports.dart';
import 'package:uzme/core/models/models_exports.dart';
import 'package:uzme/routing/app_routes.dart';
import 'package:uzme/widgets/common/app_loader.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/widgets/studio/artist_card.dart';

/// Artists list page
class ArtistsPage extends StatefulWidget {
  const ArtistsPage({super.key});

  @override
  State<ArtistsPage> createState() => _ArtistsPageState();
}

class _ArtistsPageState extends State<ArtistsPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.artists),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchArtistHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Artists list
          Expanded(
            child: BlocBuilder<ArtistBloc, ArtistState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const AppLoader();
                }

                if (state.artists.isEmpty) {
                  return _buildEmptyState(context);
                }

                final filteredArtists = _filterArtists(state.artists);

                if (filteredArtists.isEmpty) {
                  return _buildNoResultsState(context);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticatedState) {
                      context.read<ArtistBloc>().add(
                            LoadArtistsEvent(studioId: authState.user.uid),
                          );
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredArtists.length,
                    itemBuilder: (context, index) {
                      return ArtistCard(artist: filteredArtists[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: Responsive.fabBottomOffset + MediaQuery.of(context).viewPadding.bottom),
        child: FloatingActionButton.extended(
          onPressed: () => context.push(AppRoutes.artistAdd),
          icon: const FaIcon(FontAwesomeIcons.userPlus, size: 18),
          label: Text(l10n.add),
        ),
      ),
    );
  }

  List<Artist> _filterArtists(List<Artist> artists) {
    if (_searchQuery.isEmpty) return artists;
    final query = _searchQuery.toLowerCase();
    return artists.where((a) {
      return a.name.toLowerCase().contains(query) ||
          (a.stageName?.toLowerCase().contains(query) ?? false) ||
          (a.email?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.userSlash,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noArtistEmpty,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addFirstArtist,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.artistAdd),
            icon: const FaIcon(FontAwesomeIcons.userPlus, size: 16),
            label: Text(l10n.addArtist),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.magnifyingGlass,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noResult,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tryAnotherSearch,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

}
