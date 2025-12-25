import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/services/invitation_service.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Widget de recherche d'artistes existants
class ArtistSearchWidget extends StatefulWidget {
  final String studioId;
  final Function(AppUser user) onUserSelected;
  final VoidCallback onCreateNew;

  const ArtistSearchWidget({
    super.key,
    required this.studioId,
    required this.onUserSelected,
    required this.onCreateNew,
  });

  @override
  State<ArtistSearchWidget> createState() => _ArtistSearchWidgetState();
}

class _ArtistSearchWidgetState extends State<ArtistSearchWidget> {
  final _searchController = TextEditingController();
  final _invitationService = InvitationService();

  List<AppUser> _results = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.length < 2) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      List<AppUser> results;

      // Recherche par email si contient @
      if (query.contains('@')) {
        results = await _invitationService.searchArtistsByEmail(query);
      } else {
        results = await _invitationService.searchArtistsByName(query);
      }

      // Filtrer ceux déjà liés au studio
      final filtered = <AppUser>[];
      for (final user in results) {
        final isLinked = await _invitationService.isUserLinkedToStudio(
          user.uid,
          widget.studioId,
        );
        if (!isLinked) filtered.add(user);
      }

      setState(() => _results = filtered);
    } catch (e) {
      debugPrint('Erreur recherche: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: l10n.searchByNameOrEmail,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _results = []);
                        },
                      )
                    : null,
          ),
        ),
        const SizedBox(height: 16),

        // Results or empty state
        if (_searchController.text.length >= 2) ...[
          if (_results.isEmpty && !_isSearching)
            _buildEmptyState(theme, l10n)
          else
            ..._results.map((user) => _buildUserTile(theme, user, l10n)),
        ] else
          _buildInitialState(theme, l10n),

        const SizedBox(height: 24),

        // Create new button
        _buildCreateNewButton(theme, l10n),
      ],
    );
  }

  Widget _buildInitialState(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          FaIcon(
            FontAwesomeIcons.userGroup,
            size: 32,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.searchArtist,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.typeAtLeastTwoChars,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          FaIcon(
            FontAwesomeIcons.userSlash,
            size: 32,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noArtistFound,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.artistNotRegistered,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(ThemeData theme, AppUser user, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
          child: user.photoURL == null
              ? FaIcon(FontAwesomeIcons.user, size: 16, color: theme.colorScheme.outline)
              : null,
        ),
        title: Text(
          user.fullName,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          user.email,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
        ),
        trailing: FilledButton.icon(
          onPressed: () => widget.onUserSelected(user),
          icon: const FaIcon(FontAwesomeIcons.link, size: 14),
          label: Text(l10n.link),
        ),
      ),
    );
  }

  Widget _buildCreateNewButton(ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: InkWell(
        onTap: widget.onCreateNew,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.userPlus,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.createNewArtist,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.artistNotOnApp,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 14,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
