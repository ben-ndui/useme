import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/config/useme_theme.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/blocs/map/map_bloc.dart';
import 'package:useme/core/blocs/map/map_event.dart';
import 'package:useme/core/blocs/map/map_state.dart';
import 'package:useme/widgets/map/map_filter_sheet.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/artist/artist_home_feed.dart';
import 'package:useme/widgets/artist/studio_detail_bottom_sheet.dart';
import 'package:useme/widgets/artist/studio_selector_bottom_sheet.dart';
import 'package:useme/widgets/common/smooth_draggable_widget.dart';
import 'package:useme/widgets/map/studio_map_view.dart';

/// Artist portal - Dashboard with Map + Collapsible Feed (Viba style)
class ArtistPortalPage extends StatefulWidget {
  const ArtistPortalPage({super.key});

  @override
  State<ArtistPortalPage> createState() => _ArtistPortalPageState();
}

class _ArtistPortalPageState extends State<ArtistPortalPage> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadArtistData();
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    if (mounted) setState(() {});
  }

  void _loadArtistData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      context.read<SessionBloc>().add(
            LoadArtistSessionsEvent(artistId: authState.user.uid),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isWide = context.isTabletOrLarger;

    return BlocProvider(
      create: (context) => MapBloc(),
      child: Scaffold(
        extendBodyBehindAppBar: !isWide,
        appBar: isWide ? null : _buildMobileAppBar(theme, l10n, context),
        body: isWide
            ? _buildWideLayout(theme, l10n, context)
            : _buildMobileLayout(l10n, context),
      ),
    );
  }

  /// Mobile layout: Map + Draggable sheet overlay
  Widget _buildMobileLayout(AppLocalizations l10n, BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: StudioMapView(
            onStudioTap: (studio) => StudioDetailBottomSheet.show(context, studio),
          ),
        ),
        SlideInUp(
          duration: const Duration(milliseconds: 600),
          child: SmoothDraggableWidget(
            initial: 0.20,
            minSize: 0.20,
            maxSize: 1.0,
            bottomPadding: Responsive.fabBottomOffset,
            floatingBottomPadding: Responsive.fabBottomOffset,
            floatButtons: [
              FloatingActionButton.extended(
                heroTag: 'book',
                onPressed: () => StudioSelectorBottomSheet.showAndNavigate(context),
                icon: const FaIcon(FontAwesomeIcons.calendarPlus, size: 16),
                label: Text(l10n.book),
              ),
            ],
            bodyContent: const ArtistHomeFeed(),
          ),
        ),
      ],
    );
  }

  /// Tablet/Desktop layout: Side-by-side Map + Feed panel
  Widget _buildWideLayout(
    ThemeData theme,
    AppLocalizations l10n,
    BuildContext context,
  ) {
    return Row(
      children: [
        // Left: Map (60%)
        Expanded(
          flex: 6,
          child: Stack(
            children: [
              StudioMapView(
                onStudioTap: (studio) => StudioDetailBottomSheet.show(context, studio),
              ),
              // Floating book button on map
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton.extended(
                  heroTag: 'book',
                  onPressed: () => StudioSelectorBottomSheet.showAndNavigate(context),
                  icon: const FaIcon(FontAwesomeIcons.calendarPlus, size: 16),
                  label: Text(l10n.book),
                ),
              ),
            ],
          ),
        ),
        // Right: Feed panel (40%)
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [UseMeTheme.primaryColor, UseMeTheme.secondaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(-5, 0),
                ),
              ],
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 24, bottom: 24),
                child: const ArtistHomeFeed(isWideLayout: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  AppBar _buildMobileAppBar(
    ThemeData theme,
    AppLocalizations l10n,
    BuildContext context,
  ) {
    if (_isSearching) {
      return _buildSearchAppBar(theme, l10n, context);
    }
    return _buildDefaultAppBar(theme, l10n, context);
  }

  AppBar _buildDefaultAppBar(
    ThemeData theme,
    AppLocalizations l10n,
    BuildContext context,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: _buildCircleButton(
          theme: theme,
          icon: FontAwesomeIcons.magnifyingGlass,
          onPressed: () {
            setState(() => _isSearching = true);
            _searchFocusNode.requestFocus();
          },
        ),
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.music, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(l10n.appName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
      centerTitle: true,
      actions: [
        BlocBuilder<MapBloc, MapState>(
          buildWhen: (prev, curr) => prev.hasActiveFilters != curr.hasActiveFilters,
          builder: (context, state) {
            return _buildCircleButton(
              theme: theme,
              icon: FontAwesomeIcons.sliders,
              badge: state.hasActiveFilters,
              onPressed: () => MapFilterSheet.show(context),
            );
          },
        ),
        _buildCircleButton(
          theme: theme,
          icon: FontAwesomeIcons.bell,
          onPressed: () => context.push('/notifications'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  AppBar _buildSearchAppBar(
    ThemeData theme,
    AppLocalizations l10n,
    BuildContext context,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: _buildCircleButton(
          theme: theme,
          icon: FontAwesomeIcons.arrowLeft,
          onPressed: () {
            setState(() => _isSearching = false);
            _searchController.clear();
            _searchFocusNode.unfocus();
          },
        ),
      ),
      title: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: BlocConsumer<MapBloc, MapState>(
          listenWhen: (prev, curr) => prev.isSearchingAddress && !curr.isSearchingAddress,
          listener: (context, state) {
            // Close search mode when search completes
            if (state.searchQuery != null) {
              setState(() => _isSearching = false);
            }
          },
          buildWhen: (prev, curr) => prev.isSearchingAddress != curr.isSearchingAddress,
          builder: (context, state) {
            return Row(
              children: [
                if (state.isSearchingAddress)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(Icons.search, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: l10n.searchAddressHint,
                      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (query) {
                      if (query.trim().isNotEmpty) {
                        context.read<MapBloc>().add(SearchByAddressEvent(address: query.trim()));
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        // Only show X button when there's text to clear
        if (_searchController.text.isNotEmpty)
          _buildCircleButton(
            theme: theme,
            icon: FontAwesomeIcons.xmark,
            onPressed: () {
              _searchController.clear();
              setState(() {}); // Rebuild to hide X button
            },
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildCircleButton({
    required ThemeData theme,
    required IconData icon,
    required VoidCallback onPressed,
    bool badge = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          IconButton(
            icon: FaIcon(icon, size: 18),
            onPressed: onPressed,
          ),
          if (badge)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: UseMeTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
