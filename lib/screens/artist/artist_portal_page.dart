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
import 'package:useme/core/models/discovered_studio.dart';
import 'package:useme/core/blocs/map/map_event.dart';
import 'package:useme/core/blocs/map/map_state.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/artist/artist_home_feed.dart';
import 'package:useme/widgets/artist/studio_detail_bottom_sheet.dart';
import 'package:useme/widgets/artist/studio_selector_bottom_sheet.dart';
import 'package:useme/core/services/pro_profile_service.dart';
import 'package:useme/widgets/pro/pro_detail_bottom_sheet.dart';
import 'package:useme/widgets/common/smooth_draggable_widget.dart';
import 'package:useme/widgets/map/floating_nav_widget.dart';
import 'package:useme/widgets/map/map_filter_sheet.dart';
import 'package:useme/widgets/map/studio_map_view.dart';

/// Artist portal - Dashboard with Map + Collapsible Feed
class ArtistPortalPage extends StatefulWidget {
  const ArtistPortalPage({super.key});

  @override
  State<ArtistPortalPage> createState() => _ArtistPortalPageState();
}

class _ArtistPortalPageState extends State<ArtistPortalPage> {
  @override
  void initState() {
    super.initState();
    _loadArtistData();
  }

  void _openStudioDetail(BuildContext ctx, DiscoveredStudio studio) async {
    if (studio.isPro) {
      await _showProDetail(ctx, studio);
    } else {
      await StudioDetailBottomSheet.show(ctx, studio);
    }
    // Deselect so the same studio can be tapped/searched again
    if (ctx.mounted) {
      ctx.read<MapBloc>().add(const DeselectStudioEvent());
    }
  }

  Future<void> _showProDetail(BuildContext ctx, DiscoveredStudio studio) async {
    final userId = studio.proUserId;
    if (userId == null) return;
    final user = await ProProfileService().getProUser(userId);
    if (user != null && ctx.mounted) {
      await ProDetailBottomSheet.show(ctx, user);
    }
  }

  void _loadArtistData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      context.read<SessionBloc>().add(
            LoadArtistSessionsEvent(artistId: authState.user.uid),
          );
      context.read<ProProfileBloc>().add(const SearchProsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    // On tablet, the scaffold already has a NavigationRail — no bottom nav
    final isWide = context.isTabletOrLarger;
    final bottomPadding = isWide ? 16.0 : Responsive.fabBottomOffset;

    return BlocProvider(
      create: (context) => MapBloc(),
      child: BlocListener<MapBloc, MapState>(
        listenWhen: (prev, curr) =>
            prev.selectedStudio != curr.selectedStudio &&
            curr.selectedStudio != null,
        listener: (context, state) {
          _openStudioDetail(context, state.selectedStudio!);
        },
        child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(theme, l10n, context),
        body: Stack(
          children: [
            Positioned.fill(
              child: const StudioMapView(),
            ),
            const FloatingNavWidget(),
            SlideInUp(
              duration: const Duration(milliseconds: 600),
              child: SmoothDraggableWidget(
                initial: 0.20,
                minSize: 0.20,
                maxSize: 1.0,
                bottomPadding: bottomPadding,
                floatingBottomPadding: bottomPadding,
                floatButtons: [
                  Container(
                    margin: EdgeInsets.only(bottom: isWide ? 8 : 10),
                    child: FloatingActionButton.extended(
                      heroTag: 'book',
                      onPressed: () =>
                          StudioSelectorBottomSheet.showAndNavigate(context),
                      icon: const FaIcon(FontAwesomeIcons.calendarPlus,
                          size: 16),
                      label: Text(l10n.book),
                    ),
                  ),
                ],
                bodyContent: const ArtistHomeFeed(),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  AppBar _buildAppBar(
    ThemeData theme,
    AppLocalizations l10n,
    BuildContext context,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
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
            FaIcon(FontAwesomeIcons.music,
                size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(l10n.appName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
      centerTitle: true,
      actions: [
        BlocBuilder<MapBloc, MapState>(
          buildWhen: (prev, curr) =>
              prev.hasCameraMoved != curr.hasCameraMoved ||
              prev.isLoading != curr.isLoading ||
              prev.hasActiveFilters != curr.hasActiveFilters,
          builder: (context, state) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.hasCameraMoved && !state.isLoading)
                  _buildCircleButton(
                    theme: theme,
                    icon: FontAwesomeIcons.magnifyingGlassLocation,
                    onPressed: () => context.read<MapBloc>().add(
                          SearchInAreaEvent(center: state.searchCenter),
                        ),
                  ),
                _buildCircleButton(
                  theme: theme,
                  icon: FontAwesomeIcons.sliders,
                  badge: state.hasActiveFilters,
                  onPressed: () => MapFilterSheet.show(context),
                ),
              ],
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
