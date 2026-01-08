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
  @override
  void initState() {
    super.initState();
    _loadArtistData();
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
            bottomPadding: 100,
            floatingBottomPadding: MediaQuery.of(context).size.height * 0.14,
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
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
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
            FaIcon(
              FontAwesomeIcons.music,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.appName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
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
          child: IconButton(
            icon: const FaIcon(FontAwesomeIcons.bell, size: 18),
            onPressed: () => context.push('/notifications'),
          ),
        ),
      ],
    );
  }
}
